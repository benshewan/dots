-- zai_usage: Z.ai GLM Coding Plan usage HUD for maki.
-- Polls GET https://api.z.ai/api/monitor/usage/quota/limit with the key
-- maki itself stores in <state_dir>/auth/zai.json and shows the rolling
-- 5h / weekly token windows plus the monthly MCP-call quota:
--   * a compact line in the status-bar hints, refreshed after every fetch
--   * a popup with reset timers via /zai-usage
--
-- This plugin is for the user only: it registers no model-facing tool, so
-- the numbers never enter a prompt unless the user reads them off the screen.
--
-- The endpoint is undocumented (community reverse-engineered, same XHR the
-- z.ai dashboard uses). Response shape (verified 2026-09):
--   { code = 200, data = { level = "pro", limits = {
--     { type = "TOKENS_LIMIT", unit = 3, number = 5, percentage = 17,
--       nextResetTime = <epoch ms> },           -- 5h rolling window
--     { type = "TOKENS_LIMIT", unit = 6, number = 1, percentage = 57, ... },
--                                                -- weekly window
--     { type = "TIME_LIMIT", unit = 5, number = 1, percentage = 0,
--       remaining = 1000, usageDetails = {...} } -- monthly MCP calls
--   } } }
-- unit codes seen: 3 = hours, 5 = months, 6 = weeks.
-- China-region keys (open.bigmodel.cn) are NOT handled: maki's zai.json key
-- is a global-region key and the hosts are not interchangeable.
--
-- NOTE: fetches go through curl via maki.fn.jobstart, NOT maki.net.request.
-- maki's net module deadlocks when resolving the host inside the plugin
-- executor (upstream bug in maki-lua/src/api/net.rs), so every request from
-- Lua hangs forever. jobs + curl are immune to that.

local API_URL = "https://api.z.ai/api/monitor/usage/quota/limit"
local POLL_MS = 5 * 60 * 1000        -- background poll cadence
local FETCH_COOLDOWN_SECS = 20       -- skip event-driven refetches fresher than this
-- wide enough for the longest row: bars + reset timer + MCP remaining
local WIN_WIDTH = 56
-- open_win/set_config height counts the whole frame, borders included, so
-- content rows need this much on top when the border is not "none".
local BORDER_ROWS = 2

-- unit code -> short suffix, for the row label ("5h", "1w", "1mo")
local UNIT_NAMES = { [2] = "min", [3] = "h", [4] = "d", [5] = "mo", [6] = "w" }

local state = {
  key = nil,
  usage = nil, -- { level = "pro", limits = { {...}, ... } }
  fetched_at = nil,
  err = nil,
  win = nil,
  buf = nil,
  win_rows = nil, -- content rows the open window was sized for
  job_id = nil,      -- live curl job while a fetch is in flight
  poll_timer = nil,  -- pending defer_fn handle for the background poll
  fetching = false,  -- one fetch at a time, uses the freshness cooldown
  stopping = false,  -- set by SessionEnd teardown; blocks new work
  warned_key = false,
}

-- A missing/logged-out key is re-tried on every fetch but logged only once:
-- the poller runs every POLL_MS and would otherwise fill the log.
local function warn_key_once(msg)
  if not state.warned_key then
    state.warned_key = true
    maki.log.warn("zai_usage: " .. msg)
  end
end

local function read_key()
  if state.key then
    return state.key
  end
  local path = maki.fs.joinpath(maki.env.state_dir(), "auth", "zai.json")
  local text, err = maki.fs.read(path)
  if not text then
    warn_key_once("cannot read maki auth file: " .. tostring(err))
    return nil
  end
  local ok, data = pcall(maki.json.decode, text)
  if not ok or type(data) ~= "table" or type(data.api_key) ~= "string" or data.api_key == "" then
    warn_key_once("no api_key in maki auth/zai.json")
    return nil
  end
  state.key = data.api_key
  state.warned_key = false
  return state.key
end

-- nextResetTime is epoch milliseconds; compare against the current UTC epoch
-- (os.time() is already epoch-based, timezone only matters for display, and
-- there is none here - just a duration).
local function until_str(resets_ms)
  local ms = tonumber(resets_ms)
  if not ms then
    return nil
  end
  local secs = math.floor(ms / 1000) - os.time()
  if secs < 0 then
    return "now"
  end
  local hh = math.floor(secs / 3600)
  local mm = math.floor((secs % 3600) / 60)
  if hh >= 24 then
    local dd = math.floor(hh / 24)
    return string.format("%dd%02dh", dd, hh % 24)
  end
  if hh > 0 then
    return string.format("%dh%02dm", hh, mm)
  end
  return string.format("%dm", mm)
end

local function bar(percent, width)
  width = width or 14
  local filled = math.floor((percent / 100) * width + 0.5)
  filled = math.max(0, math.min(width, filled))
  return string.rep("█", filled) .. string.rep("░", width - filled)
end

-- NOTE on teardown: maki waits for the Lua runtime to go idle before
-- exiting and its join timeout costs ~60s, so anything pending at shutdown
-- hangs exit. The poller stays armed while maki runs, but the "SessionEnd"
-- autocmd (fired ahead of the join) stops the timer and the in-flight curl
-- job, so the runtime goes idle immediately. See the SessionEnd block at
-- the bottom.
local function curl_get(url, key)
  local args = { "curl", "-fsS", "--max-time", "15" }
  if key then
    args[#args + 1] = "-H"
    args[#args + 1] = "Authorization: Bearer " .. key
  end
  args[#args + 1] = url
  local id = maki.fn.jobstart(args)
  state.job_id = id
  local res = maki.fn.jobwait(id, 20000)
  state.job_id = nil
  if not res then
    maki.fn.jobstop(id)
    return nil, "timed out"
  end
  if res.exit_code ~= 0 then
    return nil, "curl exited " .. res.exit_code .. ": " .. tostring(res.stderr and res.stderr ~= "" and res.stderr or res.stdout)
  end
  return res.stdout
end

local function fetch_usage()
  local key = read_key()
  if not key then
    return nil, "no z.ai key"
  end
  local body, err = curl_get(API_URL, key)
  if not body then
    -- auth failures (401 via curl exit 22) can mean the stored key is
    -- stale after a re-login: drop the cache so the next fetch re-reads
    state.key = nil
    return nil, err
  end
  local ok, data = pcall(maki.json.decode, body)
  if not ok or type(data) ~= "table" or type(data.data) ~= "table"
    or type(data.data.limits) ~= "table" then
    return nil, "unexpected response"
  end
  state.usage = data.data
  state.fetched_at = os.time()
  state.err = nil
  return state.usage
end

-- Row label: the window size ("5h", "1w") plus what it counts. TOKENS_LIMIT
-- rows are the prompt-pool token windows, TIME_LIMIT rows count MCP tool
-- calls, so they get a distinct name.
local function row_label(lim)
  local n = tonumber(lim.number) or 1
  local unit = UNIT_NAMES[tonumber(lim.unit)] or "?"
  local size = (n == 1 and unit) or (n .. unit)
  if lim.type == "TIME_LIMIT" then
    return size .. " mcp"
  end
  return size
end

-- Build the popup content as a fresh lines table (NEVER buf:line-append:
-- re-rendering must replace the buffer contents or every refresh grows the
-- buffer and a dead scrollbar appears in the fixed-size window). Returns
-- the lines for sizing too.
local function render(buf)
  local usage = state.usage
  -- window border already carries the title; first content row is blank
  local lines = {{}}
  local function add(l)
    lines[#lines + 1] = l
  end
  if not usage then
    add({ { "  " .. (state.err or "no data yet"), "dim" } })
  else
    if type(usage.level) == "string" and usage.level ~= "" then
      add({ { "  plan ", "dim" }, { usage.level, "key" } })
    end
    for _, lim in ipairs(usage.limits or {}) do
      local pct = tonumber(lim.percentage) or 0
      local spans = {
        { string.format("  %-6s ", row_label(lim)), "key" },
        { bar(pct) .. " ", pct >= 90 and "error" or (pct >= 70 and "warn" or "ok") },
        { string.format("%3d%%", pct), "key" },
      }
      local resets = until_str(lim.nextResetTime)
      if resets then
        spans[#spans + 1] = { "  resets in " .. resets, "dim" }
      end
      local remaining = tonumber(lim.remaining)
      if remaining and lim.type == "TIME_LIMIT" then
        spans[#spans + 1] = { string.format("  %d calls left", remaining), "dim" }
      end
      add(spans)
    end
  end
  buf:set_lines(lines)
  return #lines
end

-- Make the window exactly content-sized. A set_config-only resize has
-- on this host failed while pcall swallowed the error, leaving the content
-- taller than the window (dead scrollbar) - so failures here are logged
-- and the window is rebuilt with the right size instead of trusted.
local function show_win(rows, fresh_buf)
  if state.win and state.win:is_open() then
    local ok, err = pcall(state.win.set_config, state.win, { height = rows + BORDER_ROWS })
    if ok then
      state.win_rows = rows
      return
    end
    maki.log.debug("zai_usage: set_config failed, rebuilding window: " .. tostring(err))
    state.win:close()
    state.win = nil
  end
  local buf = fresh_buf or state.buf
  state.buf = buf
  state.win = maki.ui.open_win(buf, {
    title = "z.ai coding plan",
    width = WIN_WIDTH,
    height = rows + BORDER_ROWS,
    anchor = "NE",
    row = 1,
    col = 1,
    border = "rounded",
    focus = false,
    stack = true,
  })
  state.win_rows = rows
end

local function refresh_view()
  if state.win and state.win:is_open() and state.buf then
    local rows = render(state.buf)
    if rows ~= state.win_rows then
      show_win(rows)
    end
  end
end

-- The status-bar hint only shows while a z.ai model is selected; the popup
-- works regardless.
local function on_zai_model()
  local ok, m = pcall(maki.model.get)
  return ok and m ~= nil and m.provider == "zai"
end

local function set_hint()
  if not on_zai_model() then
    pcall(maki.ui.set_status_hint, {})
    return
  end
  local usage = state.usage
  if not usage then
    return
  end
  local parts = {}
  for _, lim in ipairs(usage.limits or {}) do
    parts[#parts + 1] = string.format("%s %d%%", row_label(lim), tonumber(lim.percentage) or 0)
  end
  maki.ui.set_status_hint({ { "zai: " .. table.concat(parts, " · "), "dim" } })
end

-- Fetch data unless it is already fresh (newer than {min_age} seconds) or a
-- fetch is in flight. Returns ok, usage, err.
local function fetch_if_stale(min_age)
  if state.fetching then
    return false, nil, "busy"
  end
  if state.fetched_at and (os.time() - state.fetched_at) < min_age then
    return false, state.usage, nil
  end
  state.fetching = true
  local usage, err = fetch_usage()
  state.fetching = false
  return true, usage, err
end

local function refresh(after_fetch)
  if state.stopping then
    return
  end
  maki.async.run(function()
    maki.log.debug("zai_usage: fetch start")
    local fetched, usage, err = fetch_if_stale(FETCH_COOLDOWN_SECS)
    maki.log.debug("zai_usage: fetch done fetched=" .. tostring(fetched) .. " ok=" .. tostring(usage ~= nil))
    if state.stopping then
      -- teardown raced us; drop the result instead of touching the UI
      return
    end
    if fetched and usage then
      pcall(set_hint)
    elseif fetched and not usage then
      state.err = err
      maki.log.debug("zai_usage: fetch failed: " .. tostring(err))
    end
    pcall(refresh_view)
    if after_fetch then
      after_fetch()
    end
  end)
end

local function schedule_poll(ms)
  if state.stopping then
    return
  end
  if state.poll_timer then
    state.poll_timer:stop()
  end
  state.poll_timer = maki.defer_fn(function()
    state.poll_timer = nil
    if state.stopping then
      return
    end
    -- fetch, then re-arm the timer, all inside this async task so the
    -- runtime is idle whenever a turn is not running
    refresh(function()
      schedule_poll(POLL_MS)
    end)
  end, ms or POLL_MS)
end

local function close_win()
  if state.win then
    state.win:close()
    state.win = nil
    state.buf = nil
    state.win_rows = nil
  end
end

local function toggle_win()
  if state.win then
    close_win()
    return
  end
  local buf = maki.ui.buf()
  state.buf = buf
  show_win(render(buf))
end

maki.api.register_command({
  name = "/zai-usage",
  description = "Toggle the Z.ai Coding Plan usage popup",
  handler = function()
    refresh()
    toggle_win()
  end,
})

maki.api.create_autocmd("TurnEnd", {
  callback = function()
    refresh() -- quota may have moved
  end,
})

maki.api.create_autocmd({ "ModelChanged", "SessionFocusChanged" }, {
  callback = function()
    refresh()
  end,
})

maki.api.create_autocmd("SessionEnd", {
  callback = function(ev)
    -- Only teardown-shaped reasons are followed by the runtime join whose
    -- ~60s idle wait our pending timer would hit: "shutdown" (quit),
    -- "reload" (/reload rebuilds the host), "replaced" (ACP takeover) and
    -- "completed" (headless run done). "reset" (/new), "load" (restore)
    -- and "delete" (a tab closed) leave the host and other sessions alive,
    -- so polling continues.
    local reason = ev.data and ev.data.reason or "shutdown"
    if reason ~= "shutdown" and reason ~= "reload"
      and reason ~= "replaced" and reason ~= "completed" then
      return
    end
    state.stopping = true
    if state.poll_timer then
      state.poll_timer:stop()
      state.poll_timer = nil
    end
    if state.job_id then
      maki.fn.jobstop(state.job_id)
      state.job_id = nil
    end
    close_win()
  end,
})

-- Startup: never do network/UI work directly inside init.lua execution
-- (that deadlocked maki's startup); defer the first fetch past load and
-- start the poll loop from there. The hint only shows while a z.ai model
-- is selected.
maki.defer_fn(function()
  refresh(function()
    schedule_poll(POLL_MS)
  end)
end, 3000)

-- opencode_usage: OpenCode Go usage HUD for maki.
-- Polls GET https://opencode.ai/zen/go/v1/usage with the key maki itself
-- stores in <state_dir>/auth/opencode-go.json and shows the rolling 5h /
-- weekly / monthly limit percentages:
--   * a compact line in the status-bar hints, refreshed after every fetch
--   * a popup with reset timers via /opencode-usage
--
-- This plugin is for the user only: it registers no model-facing tool, so
-- the numbers never enter a prompt unless the user reads them off the screen.
--
-- NOTE: fetches go through curl via maki.fn.jobstart, NOT maki.net.request.
-- maki's net module deadlocks when resolving the host inside the plugin
-- executor (upstream bug in maki-lua/src/api/net.rs), so every request from
-- Lua hangs forever. jobs + curl are immune to that. The net.request path
-- is a fallback for machines without curl, where this plugin then costs
-- one 60s stall at teardown (see git history); prefer installing curl.

local API_URL = "https://opencode.ai/zen/go/v1/usage"
local POLL_MS = 5 * 60 * 1000        -- background poll cadence
local FETCH_COOLDOWN_SECS = 20       -- skip event-driven refetches fresher than this
-- wide enough for the longest row: bars + reset timer, and the decode
-- line "~999 tok/s last turn"
local WIN_WIDTH = 56
-- open_win/set_config height counts the whole frame, borders included, so
-- content rows need this much on top when the border is not "none".
local BORDER_ROWS = 2

local state = {
  key = nil,
  usage = nil, -- { rolling = {...}, weekly = {...}, monthly = {...} }
  fetched_at = nil,
  err = nil,
  win = nil,
  buf = nil,
  win_rows = nil, -- content rows the open window was sized for
  job_id = nil,      -- live curl job while a fetch is in flight
  poll_timer = nil,  -- pending defer_fn handle for the background poll
  fetching = false,  -- one fetch at a time, uses the freshness cooldown
  stopping = false,  -- set by SessionEnd teardown; blocks new work
}

local LABELS = {
  rolling = "5h",
  weekly = "week",
  monthly = "month",
}

-- A missing/logged-out key is re-tried on every fetch but logged only once:
-- the poller runs every POLL_MS and would otherwise fill the log.
local function warn_key_once(msg)
  if not state.warned_key then
    state.warned_key = true
    maki.log.warn("opencode_usage: " .. msg)
  end
end

local function read_key()
  if state.key then
    return state.key
  end
  local path = maki.fs.joinpath(maki.env.state_dir(), "auth", "opencode-go.json")
  local text, err = maki.fs.read(path)
  if not text then
    warn_key_once("cannot read maki auth file: " .. tostring(err))
    return nil
  end
  local ok, data = pcall(maki.json.decode, text)
  if not ok or type(data) ~= "table" or type(data.api_key) ~= "string" or data.api_key == "" then
    warn_key_once("no api_key in maki auth/opencode-go.json")
    return nil
  end
  state.key = data.api_key
  state.warned_key = false
  return state.key
end

-- resetsAt is UTC, and os.time() reads its table as local time while
-- guessing DST, so no os.time() conversion is used here: civil dates are
-- turned into epochs with plain arithmetic (days since 1970-01-01), which
-- is exact in every timezone. Verified against America/New_York and
-- Asia/Tokyo, where the os.time() routes were off by the UTC offset.
local function days_from_civil(y, m, d)
  y = m <= 2 and y - 1 or y
  local era = math.floor(y / 400)
  local yoe = y - era * 400
  local doy = math.floor((153 * (m + (m > 2 and -3 or 9)) + 2) / 5) + d - 1
  local doe = yoe * 365 + math.floor(yoe / 4) - math.floor(yoe / 100) + doy
  return era * 146097 + doe - 719468
end

local function utc_epoch(y, mo, d, h, mi, sec)
  return days_from_civil(y, mo, d) * 86400 + h * 3600 + mi * 60 + sec
end

local function until_str(resets_at)
  if type(resets_at) ~= "string" then
    return nil
  end
  local y, mo, d, h, mi, sec = resets_at:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
  if not y then
    return nil
  end
  local reset = utc_epoch(
    tonumber(y), tonumber(mo), tonumber(d),
    tonumber(h), tonumber(mi), tonumber(sec)
  )
  local now = os.date("!*t")
  local secs = reset - utc_epoch(now.year, now.month, now.day, now.hour, now.min, now.sec)
  if secs < 0 then
    return "now"
  end
  local hh = math.floor(secs / 3600)
  local mm = math.floor((secs % 3600) / 60)
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

local function http_get(url, key)
  if maki.fn.executable("curl") then
    return curl_get(url, key)
  end
  -- No curl: maki.net.request cannot be used as a fallback. It deadlocks
  -- resolving the host (upstream net.rs bug), so the fetch would never
  -- return, `fetching` would stay true forever and every later fetch would
  -- be skipped as busy. Refusing keeps the plugin's state honest.
  return nil, "curl not found on PATH (required; maki.net.request deadlocks)"
end

local function fetch_usage()
  local key = read_key()
  if not key then
    return nil, "no opencode-go key"
  end
  local body, err = http_get(API_URL, key)
  if not body then
    -- auth failures (401 via curl exit 22) can mean the stored key is
    -- stale after a re-login: drop the cache so the next fetch re-reads
    state.key = nil
    return nil, err
  end
  local ok, data = pcall(maki.json.decode, body)
  if not ok or type(data) ~= "table" or type(data.usage) ~= "table" then
    return nil, "unexpected response"
  end
  state.usage = data.usage
  state.fetched_at = os.time()
  state.err = nil
  return state.usage
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
    for _, name in ipairs({ "rolling", "weekly", "monthly" }) do
      local w = usage[name]
      if w then
        local pct = tonumber(w.percent) or 0
        local spans = {
          { string.format("  %-5s ", LABELS[name] or name), "key" },
          { bar(pct) .. " ", pct >= 90 and "error" or (pct >= 70 and "warn" or "ok") },
          { string.format("%3d%%", pct), "key" },
        }
        local resets = w.resetsAt and until_str(w.resetsAt)
        if resets then
          spans[#spans + 1] = { "  resets in " .. resets, "dim" }
        end
        if w.status and w.status ~= "ok" then
          spans[#spans + 1] = { "  " .. w.status, "error" }
        end
        add(spans)
      end
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
    maki.log.debug("opencode_usage: set_config failed, rebuilding window: " .. tostring(err))
    state.win:close()
    state.win = nil
  end
  local buf = fresh_buf or state.buf
  state.buf = buf
  state.win = maki.ui.open_win(buf, {
    title = "opencode go",
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

-- The status-bar hint only shows while an OpenCode Go model is selected;
-- the popup works regardless.
local function on_go_model()
  local ok, m = pcall(maki.model.get)
  return ok and m ~= nil and m.provider == "opencode-go"
end

local function set_hint()
  if not on_go_model() then
    pcall(maki.ui.set_status_hint, {})
    return
  end
  local usage = state.usage
  if not usage then
    return
  end
  local parts = {}
  for _, name in ipairs({ "rolling", "weekly", "monthly" }) do
    local w = usage[name]
    if w then
      parts[#parts + 1] = string.format("%s %d%%", LABELS[name], tonumber(w.percent) or 0)
    end
  end
  maki.ui.set_status_hint({ { "go: " .. table.concat(parts, " · "), "dim" } })
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
    maki.log.debug("opencode_usage: fetch start")
    local fetched, usage, err = fetch_if_stale(FETCH_COOLDOWN_SECS)
    maki.log.debug("opencode_usage: fetch done fetched=" .. tostring(fetched) .. " ok=" .. tostring(usage ~= nil))
    if state.stopping then
      -- teardown raced us; drop the result instead of touching the UI
      return
    end
    if fetched and usage then
      pcall(set_hint)
    elseif fetched and not usage then
      state.err = err
      maki.log.debug("opencode_usage: fetch failed: " .. tostring(err))
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
  name = "/opencode-usage",
  description = "Toggle the OpenCode Go usage limits popup",
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
-- start the poll loop from there. The hint only shows while an OpenCode
-- Go model is selected.
maki.defer_fn(function()
  refresh(function()
    schedule_poll(POLL_MS)
  end)
end, 3000)

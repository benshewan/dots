-- opencode_usage: OpenCode Go usage HUD for maki.
-- Polls GET https://opencode.ai/zen/go/v1/usage with the key maki itself
-- stores in <state_dir>/auth/opencode-go.json and shows the rolling 5h /
-- weekly / monthly limit percentages:
--   * a compact line in the status-bar hints, refreshed after every fetch
--   * a popup with reset timers via /opencode-usage
--   * a tool ("opencode_usage") the model can call
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
local TOOL_STALE_SECS = 120          -- the tool refetches when data is older
local WIN_WIDTH = 46

local state = {
  key = nil,
  usage = nil, -- { rolling = {...}, weekly = {...}, monthly = {...} }
  fetched_at = nil,
  err = nil,
  win = nil,
  buf = nil,
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

local function read_key()
  if state.key then
    return state.key
  end
  local path = maki.fs.joinpath(maki.env.state_dir(), "auth", "opencode-go.json")
  local text, err = maki.fs.read(path)
  if not text then
    maki.log.warn("opencode_usage: cannot read maki auth file: " .. tostring(err))
    return nil
  end
  local ok, data = pcall(maki.json.decode, text)
  if not ok or type(data) ~= "table" or type(data.api_key) ~= "string" or data.api_key == "" then
    maki.log.warn("opencode_usage: no api_key in maki auth/opencode-go.json")
    return nil
  end
  state.key = data.api_key
  return state.key
end

local function parse_iso(s)
  local y, mo, d, h, mi, sec = s:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
  if not y then
    return nil
  end
  return os.time({ year = y, month = mo, day = d, hour = h, min = mi, sec = sec })
end

local function until_str(resets_at)
  local t = parse_iso(resets_at)
  if not t then
    return ""
  end
  local secs = t - os.time()
  if secs < 0 then
    return "now"
  end
  local h = math.floor(secs / 3600)
  local m = math.floor((secs % 3600) / 60)
  if h > 0 then
    return string.format("%dh%02dm", h, m)
  end
  return string.format("%dm", m)
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
  local res, err = maki.net.request(url, {
    headers = key and { Authorization = "Bearer " .. key } or {},
    timeout = 15,
  })
  if not res then
    return nil, err
  end
  if res.status ~= 200 then
    return nil, "HTTP " .. res.status
  end
  return res.body
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

local function render(buf)
  local usage = state.usage
  buf:set_lines({ " opencode go" })
  if not usage then
    buf:line("")
    buf:line({ { "  " .. (state.err or "no data yet"), "dim" } })
    return
  end
  buf:line("")
  for _, name in ipairs({ "rolling", "weekly", "monthly" }) do
    local w = usage[name]
    if w then
      local pct = tonumber(w.percent) or 0
      local spans = {
        { string.format("  %-5s ", LABELS[name] or name), "key" },
        { bar(pct) .. " ", pct >= 90 and "error" or (pct >= 70 and "warn" or "ok") },
        { string.format("%3d%%", pct), "key" },
      }
      if w.resetsAt then
        spans[#spans + 1] = { "  resets in " .. until_str(w.resetsAt), "dim" }
      end
      if w.status and w.status ~= "ok" then
        spans[#spans + 1] = { "  " .. w.status, "error" }
      end
      buf:line(spans)
    end
  end
end

local function refresh_view()
  if state.win and state.win:is_open() and state.buf then
    render(state.buf)
  end
end

-- The status-bar hint only shows while an OpenCode Go model is selected;
-- the popup and tool work regardless.
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
  end
end

local function toggle_win()
  if state.win then
    close_win()
    return
  end
  local buf = maki.ui.buf()
  state.buf = buf
  render(buf)
  state.win = maki.ui.open_win(buf, {
    title = "opencode go",
    width = WIN_WIDTH,
    height = 7,
    anchor = "NE",
    row = 1,
    col = 1,
    border = "rounded",
    focus = false,
    stack = true,
  })
end

maki.api.register_command({
  name = "/opencode-usage",
  description = "Toggle the OpenCode Go usage limits popup",
  handler = function()
    refresh()
    toggle_win()
  end,
})

maki.api.register_tool({
  name = "opencode_usage",
  description = [[Show the user's current OpenCode Go subscription usage limits: rolling 5-hour, weekly, and monthly percentage used, plus reset timers. Use whenever the user asks about their OpenCode usage, quota, or limits.]],
  schema = { type = "object", properties = {} },
  handler = function()
    -- Serve cached data; refetch only when it is missing or stale. A call
    -- while a background fetch is in flight just serves the older cache.
    fetch_if_stale(TOOL_STALE_SECS)
    local usage = state.usage
    if not usage then
      return { llm_output = "error: " .. tostring(state.err or "no data yet"), is_error = true }
    end
    local lines = {}
    for _, name in ipairs({ "rolling", "weekly", "monthly" }) do
      local w = state.usage[name]
      if w then
        lines[#lines + 1] = string.format(
          "%s: %d%% used, status %s, resets in %s",
          LABELS[name],
          tonumber(w.percent) or 0,
          w.status or "unknown",
          until_str(w.resetsAt)
        )
      end
    end
    return { llm_output = table.concat(lines, "\n") }
  end,
})

maki.api.create_autocmd({ "TurnEnd", "ModelChanged", "SessionFocusChanged" }, {
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

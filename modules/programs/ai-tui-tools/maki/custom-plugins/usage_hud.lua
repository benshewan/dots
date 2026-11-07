-- usage_hud: shared scaffolding for the usage HUD plugins.
--
-- opencode_usage.lua and zai_usage.lua are the same HUD pointed at two
-- endpoints: poll a usage API with the key maki stores in
-- <state_dir>/auth/<auth_file>, show a popup with per-window bars and reset
-- timers behind a slash command, and publish a compact status-bar hint
-- through the shared usage_hint module. This module owns everything that
-- scaffolding shares; a plugin supplies only what differs:
--
--   name          string  log prefix and hint identity
--   api_url       string  endpoint to poll
--   auth_file     string  file under <state_dir>/auth holding { api_key = ... }
--   key_err       string  error message when the key is missing
--   win_title     string  popup border title
--   command       string  slash command that toggles the popup
--   command_desc  string  description shown in the command palette
--   provider      string  hint shows only while this provider is selected
--   parse         fn(body) -> usage, err   decode + shape-check the response
--   render_lines  fn(usage, err) -> lines  popup content as a fresh lines table
--   hint_text     fn(usage) -> string|nil  status-bar line once it has data
--
-- Fetches use maki.net.request. That used to deadlock (maki <= 0.5.x, net.rs
-- ran smol::block_on inside the plugin executor), which is why the plugins
-- shelled out to curl; net.rs is reqwest/tokio async now, so the native call
-- is safe and needs no `run` permission or curl on PATH.

local POLL_MS = 5 * 60 * 1000        -- background poll cadence
local FETCH_COOLDOWN_SECS = 20       -- skip event-driven refetches fresher than this
-- wide enough for the longest row: bar + reset timer + extras
local WIN_WIDTH = 56
-- open_win/set_config height counts the whole frame, borders included, so
-- content rows need this much on top when the border is not "none".
local BORDER_ROWS = 2

local usage_hint = require("usage_hint")

local M = {}

-- percent -> a filled/empty bar of {width} cells (default 14)
function M.bar(percent, width)
  width = width or 14
  local filled = math.floor((percent / 100) * width + 0.5)
  filled = math.max(0, math.min(width, filled))
  return string.rep("█", filled) .. string.rep("░", width - filled)
end

function M.new(spec)
  local state = {
    key = nil,
    usage = nil,      -- whatever spec.parse returned last
    fetched_at = nil,
    err = nil,
    win = nil,
    buf = nil,
    win_rows = nil,   -- content rows the open window was sized for
    poll_timer = nil, -- pending defer_fn handle for the background poll
    fetching = false, -- one fetch at a time, uses the freshness cooldown
    stopping = false, -- set by SessionEnd teardown; blocks new work
    warned_key = false,
  }

  -- A missing/logged-out key is re-tried on every fetch but logged only once:
  -- the poller runs every POLL_MS and would otherwise fill the log.
  local function warn_key_once(msg)
    if not state.warned_key then
      state.warned_key = true
      maki.log.warn(spec.name .. ": " .. msg)
    end
  end

  local function read_key()
    if state.key then
      return state.key
    end
    local path = maki.fs.joinpath(maki.env.state_dir(), "auth", spec.auth_file)
    local text, err = maki.fs.read(path)
    if not text then
      warn_key_once("cannot read maki auth file: " .. tostring(err))
      return nil
    end
    local ok, data = pcall(maki.json.decode, text)
    if not ok or type(data) ~= "table" or type(data.api_key) ~= "string" or data.api_key == "" then
      warn_key_once("no api_key in maki auth/" .. spec.auth_file)
      return nil
    end
    state.key = data.api_key
    state.warned_key = false
    return state.key
  end

  -- NOTE on teardown: a pending defer_fn timer costs the ~60s join maki does
  -- before exiting, so the poller has to be stopped ahead of it. The
  -- "SessionEnd" autocmd (fired before the join) does that, so nothing new
  -- starts. An in-flight request needs no such handling: maki.net.request is
  -- bounded by `timeout` below and teardown drops the task at once (measured,
  -- exit is instant even mid-fetch). See the SessionEnd block at the bottom.
  local function http_get(url, key)
    local headers = { Accept = "application/json" }
    if key then
      headers["Authorization"] = "Bearer " .. key
    end
    local res, err = maki.net.request(url, {
      headers = headers,
      timeout = 15,        -- seconds; keeps a stuck endpoint off the exit path
      max_bytes = 64 * 1024,
      retry = 0,          -- one bounded attempt per poll, no 5xx backoff stack
    })
    if not res then
      return nil, err
    end
    if res.status < 200 or res.status >= 300 then
      local snippet = (res.body or ""):gsub("%s+", " "):sub(1, 120)
      return nil, string.format("http %d%s", res.status, snippet ~= "" and (": " .. snippet) or "")
    end
    return res.body
  end

  local function fetch_usage()
    local key = read_key()
    if not key then
      return nil, spec.key_err
    end
    local body, err = http_get(spec.api_url, key)
    if not body then
      -- auth failures (http 401/403) can mean the stored key is stale after
      -- a re-login: drop the cache so the next fetch re-reads. Transport
      -- errors and 5xx keep the cached key.
      if err and (err:find("http 401", 1, true) or err:find("http 403", 1, true)) then
        state.key = nil
      end
      return nil, err
    end
    local usage, parse_err = spec.parse(body)
    if not usage then
      return nil, parse_err or "unexpected response"
    end
    state.usage = usage
    state.fetched_at = os.time()
    state.err = nil
    return state.usage
  end

  -- Fetch data unless it is already fresh (newer than {min_age} seconds) or a
  -- fetch is in flight. Returns fetched, usage, err.
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

  -- Build the popup content as a fresh lines table (NEVER buf:line-append:
  -- re-rendering must replace the buffer contents or every refresh grows the
  -- buffer and a dead scrollbar appears in the fixed-size window). Returns
  -- the line count for sizing too.
  local function render(buf)
    local lines = spec.render_lines(state.usage, state.err)
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
      maki.log.debug(spec.name .. ": set_config failed, rebuilding window: " .. tostring(err))
      state.win:close()
      state.win = nil
    end
    local buf = fresh_buf or state.buf
    state.buf = buf
    state.win = maki.ui.open_win(buf, {
      title = spec.win_title,
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

  local function refresh(after_fetch)
    if state.stopping then
      return
    end
    maki.async.run(function()
      maki.log.debug(spec.name .. ": fetch start")
      local fetched, usage, err = fetch_if_stale(FETCH_COOLDOWN_SECS)
      maki.log.debug(spec.name .. ": fetch done fetched=" .. tostring(fetched) .. " ok=" .. tostring(usage ~= nil))
      if state.stopping then
        -- teardown raced us; drop the result instead of touching the UI
        return
      end
      if fetched and not usage then
        state.err = err
        maki.log.debug(spec.name .. ": fetch failed: " .. tostring(err))
      end
      -- Published on every refresh, not only after a fetch: the selected model
      -- may have changed, and the data may already be fresh.
      pcall(usage_hint.refresh)
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

  -- The status-bar hint only shows while the plugin's provider is selected;
  -- the popup works regardless. The hint slot is shared between the HUD
  -- plugins (every module the global init.lua requires is one maki plugin),
  -- so the line is published through usage_hint, which picks whichever of
  -- them applies.
  usage_hint.register(spec.name, {
    active = function()
      local ok, m = pcall(maki.model.get)
      return ok and m ~= nil and m.provider == spec.provider
    end,
    text = function()
      return spec.hint_text(state.usage)
    end,
  })

  maki.api.register_command({
    name = spec.command,
    description = spec.command_desc,
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
      close_win()
    end,
  })

  -- Startup: never do network/UI work directly inside init.lua execution
  -- (that deadlocked maki's startup); defer the first fetch past load and
  -- start the poll loop from there. The hint only shows while the plugin's
  -- provider is selected.
  maki.defer_fn(function()
    refresh(function()
      schedule_poll(POLL_MS)
    end)
  end, 3000)

  return {
    bar = M.bar,
    state = state,
  }
end

return M

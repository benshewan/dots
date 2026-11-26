-- usage_hud: plan-usage hint line for the selected provider.
--
-- Asks maki.provider.usage for the focused provider's plan limits — the
-- same native fetch behind /usage — and shows them as one line above the
-- input while that provider is selected. Whatever the provider reports is
-- rendered with the provider's own labels, so every provider with a usage
-- endpoint (z.ai, opencode-go, ...) is covered with no per-provider code.
--
-- This plugin is for the user only: it registers no model-facing tool, so
-- the numbers never enter a prompt unless the user reads them off the screen.
--
-- maki.provider.usage (maki after 0.7.3) is a live fetch, so calls are
-- spaced by a cooldown plus a background poll; on a maki without the API
-- this logs one warning and shows nothing instead of erroring.

local POLL_MS = 5 * 60 * 1000        -- background poll cadence
local FETCH_COOLDOWN_SECS = 20       -- skip event-driven refetches fresher than this

local state = {
  provider = nil,    -- slug state.usage was fetched for
  usage = nil,
  fetched_at = nil,
  poll_timer = nil,  -- pending defer_fn handle for the background poll
  stopping = false,  -- set by SessionEnd teardown; blocks new work
  warned_missing = false,
}

-- Last pushed text: every push redraws the status line, so repeats are
-- skipped to avoid flicker.
local last_hint = nil

local function fetch()
  if type(maki.provider) ~= "table" or type(maki.provider.usage) ~= "function" then
    if not state.warned_missing then
      state.warned_missing = true
      maki.log.warn("usage_hud: this maki has no maki.provider.usage; hint disabled")
    end
    return
  end
  local ok, m = pcall(maki.model.get)
  local provider = ok and m ~= nil and m.provider or nil
  if not provider then
    return
  end
  -- Model switch: drop the other provider's numbers before anything stale
  -- can show next to the new provider's name.
  if provider ~= state.provider then
    state.provider = provider
    state.usage = nil
    state.fetched_at = nil
  end
  -- The API fetches live data, so event-driven refreshes reuse anything
  -- fresher than the cooldown instead of hammering the endpoint.
  if state.fetched_at and (os.time() - state.fetched_at) < FETCH_COOLDOWN_SECS then
    return
  end
  local usage, err = maki.provider.usage(provider)
  state.fetched_at = os.time()
  if not usage then
    -- nil+err is normal: the provider reports no usage, or the fetch
    -- failed. Keep the last data; the hint shows it or stays absent.
    maki.log.debug("usage_hud: " .. provider .. ": " .. tostring(err))
    return
  end
  state.usage = usage
end

local function hint_text()
  if not state.usage or type(state.usage.limits) ~= "table" or #state.usage.limits == 0 then
    return nil
  end
  local parts = {}
  for _, lim in ipairs(state.usage.limits) do
    local pct = type(lim.percentage) == "number" and lim.percentage or 0
    parts[#parts + 1] = string.format("%s %d%%", tostring(lim.label):lower(), pct)
  end
  return state.provider .. ": " .. table.concat(parts, " · ")
end

-- The status-hint slot is per plugin and this is the only writer now, so
-- the line is pushed directly (no shared-slot module needed).
local function publish()
  local text = hint_text() or ""
  if text == last_hint then
    return
  end
  last_hint = text
  if text == "" then
    pcall(maki.ui.set_status_hint, {})
  else
    pcall(maki.ui.set_status_hint, { { text, "dim" } })
  end
end

local function refresh(after_fetch)
  if state.stopping then
    return
  end
  maki.async.run(function()
    fetch()
    if state.stopping then
      -- teardown raced us; skip touching the UI
      return
    end
    -- Published on every refresh, not only after a fetch: the selected
    -- model may have changed, and the data may already be fresh.
    publish()
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
  end,
})

-- Startup: never do network work directly inside init.lua execution
-- (that deadlocked maki's startup); defer the first fetch past load and
-- start the poll loop from there.
maki.defer_fn(function()
  refresh(function()
    schedule_poll(POLL_MS)
  end)
end, 3000)

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
-- Polling, fetching, the popup window and teardown live in usage_hud.lua;
-- this file only carries what is z.ai specific.

local usage_hud = require("usage_hud")

-- unit code -> short suffix, for the row label ("5h", "1w", "1mo")
local UNIT_NAMES = { [2] = "min", [3] = "h", [4] = "d", [5] = "mo", [6] = "w" }

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

usage_hud.new({
  name = "zai_usage",
  api_url = "https://api.z.ai/api/monitor/usage/quota/limit",
  auth_file = "zai.json",
  key_err = "no z.ai key",
  win_title = "z.ai coding plan",
  command = "/zai-usage",
  command_desc = "Toggle the Z.ai Coding Plan usage popup",
  provider = "zai",

  parse = function(body)
    local ok, data = pcall(maki.json.decode, body)
    if not ok or type(data) ~= "table" or type(data.data) ~= "table"
      or type(data.data.limits) ~= "table" then
      return nil, "unexpected response"
    end
    return data.data
  end,

  render_lines = function(usage, err)
    -- window border already carries the title; first content row is blank
    local lines = {{}}
    if not usage then
      lines[#lines + 1] = { { "  " .. (err or "no data yet"), "dim" } }
      return lines
    end
    if type(usage.level) == "string" and usage.level ~= "" then
      lines[#lines + 1] = { { "  plan ", "dim" }, { usage.level, "key" } }
    end
    for _, lim in ipairs(usage.limits or {}) do
      local pct = tonumber(lim.percentage) or 0
      local spans = {
        { string.format("  %-6s ", row_label(lim)), "key" },
        { usage_hud.bar(pct) .. " ", pct >= 90 and "error" or (pct >= 70 and "warn" or "ok") },
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
      lines[#lines + 1] = spans
    end
    return lines
  end,

  hint_text = function(usage)
    if not usage then
      return nil
    end
    local parts = {}
    for _, lim in ipairs(usage.limits or {}) do
      parts[#parts + 1] = string.format("%s %d%%", row_label(lim), tonumber(lim.percentage) or 0)
    end
    return "zai: " .. table.concat(parts, " · ")
  end,
})

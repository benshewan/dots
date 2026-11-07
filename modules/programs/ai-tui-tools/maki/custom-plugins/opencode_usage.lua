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
-- Polling, fetching, the popup window and teardown live in usage_hud.lua;
-- this file only carries what is OpenCode Go specific.

local usage_hud = require("usage_hud")

local LABELS = {
  rolling = "5h",
  weekly = "week",
  monthly = "month",
}

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

usage_hud.new({
  name = "opencode_usage",
  api_url = "https://opencode.ai/zen/go/v1/usage",
  auth_file = "opencode-go.json",
  key_err = "no opencode-go key",
  win_title = "opencode go",
  command = "/opencode-usage",
  command_desc = "Toggle the OpenCode Go usage limits popup",
  provider = "opencode-go",

  parse = function(body)
    local ok, data = pcall(maki.json.decode, body)
    if not ok or type(data) ~= "table" or type(data.usage) ~= "table" then
      return nil, "unexpected response"
    end
    return data.usage
  end,

  render_lines = function(usage, err)
    -- window border already carries the title; first content row is blank
    local lines = {{}}
    if not usage then
      lines[#lines + 1] = { { "  " .. (err or "no data yet"), "dim" } }
      return lines
    end
    for _, name in ipairs({ "rolling", "weekly", "monthly" }) do
      local w = usage[name]
      if w then
        local pct = tonumber(w.percent) or 0
        local spans = {
          { string.format("  %-5s ", LABELS[name] or name), "key" },
          { usage_hud.bar(pct) .. " ", pct >= 90 and "error" or (pct >= 70 and "warn" or "ok") },
          { string.format("%3d%%", pct), "key" },
        }
        local resets = w.resetsAt and until_str(w.resetsAt)
        if resets then
          spans[#spans + 1] = { "  resets in " .. resets, "dim" }
        end
        if w.status and w.status ~= "ok" then
          spans[#spans + 1] = { "  " .. w.status, "error" }
        end
        lines[#lines + 1] = spans
      end
    end
    return lines
  end,

  hint_text = function(usage)
    if not usage then
      return nil
    end
    local parts = {}
    for _, name in ipairs({ "rolling", "weekly", "monthly" }) do
      local w = usage[name]
      if w then
        parts[#parts + 1] = string.format("%s %d%%", LABELS[name], tonumber(w.percent) or 0)
      end
    end
    return "go: " .. table.concat(parts, " · ")
  end,
})

-- usage_hint: the one status-hint slot the usage HUD plugins share.
--
-- maki scopes status hints per *plugin*, and every module the global init.lua
-- requires runs under the same plugin identity ("global/init.lua"). So
-- lua/opencode_usage.lua and lua/zai_usage.lua cannot own a hint each: they
-- share a single slot, and whoever writes last wins. A plugin clearing that
-- slot whenever its own provider is not the selected one
-- (`set_status_hint({})`) therefore wiped the other's line a moment after it
-- appeared at startup.
--
-- This module owns the slot for both. Each plugin registers itself with:
--   active() -> boolean     is its provider the model in use?
--   text()   -> string|nil   the line to show, once it has data
-- refresh() recomputes the line from every registration, in registration
-- order, and pushes it once. Text identical to the last push is not pushed
-- again: every push makes the host redraw the status line, so repeats are
-- visible as flicker.
local M = {}

local entries = {}
local order = {}
local last = nil

local SEP = "  "

function M.register(id, entry)
  if not entries[id] then
    order[#order + 1] = id
  end
  entries[id] = entry
end

function M.refresh()
  local parts = {}
  for _, id in ipairs(order) do
    local e = entries[id]
    local ok, active = pcall(e.active)
    if ok and active then
      local ok2, text = pcall(e.text)
      if ok2 and text and text ~= "" then
        parts[#parts + 1] = text
      end
    end
  end
  local text = table.concat(parts, SEP)
  if text == last then
    return
  end
  last = text
  if text == "" then
    pcall(maki.ui.set_status_hint, {})
  else
    pcall(maki.ui.set_status_hint, { { text, "dim" } })
  end
end

return M

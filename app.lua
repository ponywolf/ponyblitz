local M = {}

local store = {}

function M.setVariable(k,v)
  store[k] = v
end

function M.getVariable(k,v)
  if not store[k] then print("Variable doesn't exist", k) return false end
  return store[k]
end

function M.clearVariables(k,v)
  store = {}
end

M.key = {}
local key = function(event)
  if event.keyName == "w" then event.keyName = "up" end
  if event.keyName == "s" then event.keyName = "down" end
  if event.keyName == "a" then event.keyName = "left" end
  if event.keyName == "d" then event.keyName = "right" end
  M.key[event.keyName or "none"] = (event.phase=="down")
end
Runtime:addEventListener("key", key)

return M
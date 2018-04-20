-- camera control

local M = {}

local centerX, centerY = display.contentCenterX, display.contentCenterY

function M.new()
  local instance = display.newGroup()

  function instance:center()
    -- centers the world on screen
    instance.x, instance.y = centerX, centerY
  end

  function instance:reset()
    -- places the world on screen at 0,0
    instance.x, instance.y = 0,0
  end

  function instance:centerObj(obj)
    -- moves the world, so the specified object is on screen
    if obj == nil then return false end
    
    -- easiest way to scroll a map based on a character
    -- find the difference between the hero and the display center
    -- and move the world to compensate
    local x, y = obj:localToContent(0,0)
    x, y = centerX - x, centerY - y
    self.x, self.y = self.x + x, self.y + y
  end

  return instance
end

return M
-- scanlines

local M = {}

function M.new()

  local instance = display.newGroup()
  local function build()
    for i = display.screenOriginY, display.actualContentHeight,2 do
      local rect = display.newRect(instance, display.contentCenterX, i, display.actualContentWidth, 1)
      rect:setFillColor(0,0,0,0.5)
    end
  end
  
  local function resize()
    for i = 1, instance.numChildren do
      display.remove(instance[i])
    end
    build()
  end
  
  build()
  instance.alpha = 0.25
  
  Runtime:addEventListener("resize", resize)
  
  return instance
end

return M
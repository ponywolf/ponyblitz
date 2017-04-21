-- scanlines

local M = {}

local centerX, centerY = display.contentCenterX, display.contentCenterY
local sizeX, sizeY = display.viewableContentWidth, display.viewableContentHeight

function M.new()
  local instance = display.newImageRect("scene/game/img/scanlines.png", sizeX, sizeY)
  instance.x, instance.y = centerX, centerY
  instance.blendMode = "multiply"
  instance.alpha = 0.45
  return instance
end

return M
-- lighting system

local M = {}

function M.new(ambient)
  local width = display.actualContentWidth
  local height = display.actualContentHeight
  local lights = {}
  local dim = 0

  local instance = display.newSnapshot(width, height)
  instance.x, instance.y = display.screenOriginX, display.screenOriginY
  local black = display.newRect(instance.group, 0, 0, width , height)
  black:setFillColor(ambient or 0)
  instance.blendMode = "multiply"

  function instance:addLight(object, size)
    if not object or not object.localToContent then error("ERROR: Expected display object") end
    local id = "light-" .. (#lights + 1) .. "-" .. os.clock() .. "-" .. math.random(999999)
    lights[id] = display.newImageRect(instance.group, "scene/game/img/light.png", size or 512, size or 512)
    lights[id].x, lights[id].y = object:localToContent(0,0)
    lights[id]:translate(-display.screenOriginX-width/2, -display.screenOriginY-height/2)    
    lights[id].objectToFollow = object
    transition.from (lights[id], { alpha = 0, time = 333 })
    lights[id].active = true
    return id
  end

  function instance:setAmbient(ambient)
    black:setFillColor(ambient or 0)
  end
  
  function instance:reveal()
    dim = 1
  end

  local function enterFrame(event)
    local activeLights = 0
    
    for k, v in pairs(lights) do
      if v and v.active then
        if not v.objectToFollow then
          instance:removeLight(k)
        elseif v.objectToFollow.placed and not v.objectToFollow.alwaysLit then
          instance:removeLight(k)
        elseif v.objectToFollow.localToContent then
          v.x, v.y = v.objectToFollow:localToContent(0,0)
          v:translate(-display.screenOriginX-width/2, -display.screenOriginY-height/2)
          local flicker = math.random() - math.random()
          v.xScale, v.yScale = 1 + flicker/64, 1 + flicker/64
          v.alpha = 1 - flicker/64
          activeLights = activeLights + 1
        else
          instance:removeLight(k)
        end
      end
    end
    if instance and instance.invalidate then
      instance:invalidate()
    end
    -- dim
    if black and dim > ambient then
      black:setFillColor(dim)
      dim = dim - 0.003
    end
    
  end

  function instance:removeLight(k)
    if lights[k] and lights[k].active then
      lights[k].active = false
      transition.to(lights[k], { alpha = 0, time = 1000, xScale = 0.1, yScale = 0.1, onComplete = 
          function ()
            display.remove(lights[k])
            lights[k] = nil
            --print ("removed", k)
          end })
    end
  end

  function instance:finalize()
    Runtime:removeEventListener("enterFrame", enterFrame)
  end
  
  instance:addEventListener("finalize")
  Runtime:addEventListener("enterFrame", enterFrame)

  return instance
end

return M
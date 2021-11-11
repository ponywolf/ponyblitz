-- Frame Buffer attempt via Snapshot/Canvas

--[[
MIT License

Copyright (c) 2020 Ponywolf, LLC
Copyright (c) 2018 David Bollinger

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]]


-- USAGE
-- require("render")

-- This module adds everything from the stage to a
-- "render" texture that updates at 60FPS. Think of
-- it as a fake "frame buffer"

-- It borrows some ideas from Dave Bolinger's
-- TV Shader Touch Support for the recursive
-- re-broadcast touch and tap events to objects
-- that have moved due to the render pass

-- https://github.com/davebollinger/TVShader_TouchSupport

-- I added the ability to setFocus on an object
-- in a non-multitouch environment

require "shader.crt"

local stage = display.getCurrentStage()

local render, view
local group = display.newGroup()
group._isRenderer = true

-- set focus
local setFocus = stage.setFocus
local focusedObj
function display.currentStage:setFocus(obj, id)
  focusedObj = obj
  if obj == nil then print("Focus removed") else print ("Focused on ", obj.name) end
end

local function touchable(obj)
  return obj.isVisible or obj.isHitTestable
end

local function inBounds(event, obj)
  if not event or not event.x or not event.y then return false end
  local ex, ey = event.x, event.y
  local bounds = obj.contentBounds or {}
  if bounds then
    if ex < bounds.xMin or ex > bounds.xMax or ey < bounds.yMin or ey > bounds.yMax then
      return false
    else
      return true
    end
    return false
  end
end

local function redispatchEvent(event)
  local objs = {}

  local function findTouchable(obj)
    -- Find all "touchables"
    if touchable(obj) then
      if inBounds(event, obj) then
        if obj.numChildren then
          for i = obj.numChildren, 1, -1 do
            findTouchable(obj[i])
          end
        end
        objs[#objs + 1] = obj
      end
    end
  end

  -- find "touchables"
  if focusedObj then
    objs[1] = focusedObj
  else
    for i = group.numChildren, 1, -1 do
      findTouchable(group[i])
    end
  end

  for i = 1, #objs do
    local target = objs[i]
    event.target = target
    local handled = false

    if target.dispatchEvent then
      --print("redispatchEvent ", target.name, event.phase, event.id)
      handled = target:dispatchEvent(event)
    end
    if handled then
      return target
    end
  end
end

stage:addEventListener('tap', function (e) redispatchEvent(e) return true end)
stage:addEventListener('touch', function (e) redispatchEvent(e) return true end)

local function resize(event)
  local width, height = display.actualContentWidth, display.actualContentHeight
  local centerX, centerY = display.contentCenterX, display.contentCenterY

  display.remove(render)
  render = graphics.newTexture( { type="canvas", width=width, height=height } )
  render.anchorX, render.anchorY = -(centerX/width), -(centerY/height)

  display.remove(view)
  view = display.newImageRect(render.filename, render.baseDir, width, height )
  view.anchorX, view.anchorY = 0, 0
  view.x, view.y = display.screenOriginX, display.screenOriginY
  view.fill.effect = "filter.custom.crt" -- your custom Filter Effect goes here
  view._isRenderer = true
end

local function enterFrame(event)
  render:invalidate("cache")  
  -- add anything new to the render queue
  for i = 1, display.currentStage.numChildren do
    local child = display.currentStage[i]
    if child and not child._isRenderer then
      --print("here")
      group:insert(child)
    end
  end
  -- render!
  render:draw(group)
  render:invalidate("cache")
end

-- show/hide effect
local effect = true
local function key(event)
  local phase = event.phase
  local name = event.keyName
  if phase == "up" then
    if name == "c" then
      effect = not effect
      if effect then
        view.fill.effect = "filter.custom.crt"
      else
        view.fill.effect = nil
      end
    end
  end
end

resize()
Runtime:addEventListener("key", key )
Runtime:addEventListener("resize", resize)
--Runtime:addEventListener("lateUpdate", enterFrame )
Runtime:addEventListener("enterFrame", enterFrame)
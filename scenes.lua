-- Scenes for Solar2D by ponywolf

-- define module
local M = {}

-- local
local list = {}
local stage = display.getCurrentStage()

-- public
-- scene has it's own stage
M.stage = display.newGroup()
stage:insert(M.stage)

-- scene has an always on top overlay group
M.overlay = display.newGroup()
M.overlay._isRenderer = true
stage:insert(M.overlay)

-- modal screen dim
local function dim(percent, modal)
  local instance = display.newRect(
    display.contentCenterX,
    display.contentCenterY,
    display.actualContentWidth * 2,
    display.actualContentHeight * 2)
  instance:setFillColor(0,0,0,1)
  instance.alpha = percent or 0.5
  instance.isHitTestable = true
  if modal then
    local function disable(event)
      return instance.parent and instance.parent.isVisible
    end
    instance:addEventListener("touch", disable)
    instance:addEventListener("tap", disable)
  end
  return instance
end

-- fade to black
local function fadeOut(onComplete, time, delay)
  local color = { 0, 0, 0, 1 }
  local instance = display.newRect(
    display.contentCenterX,
    display.contentCenterY,
    display.actualContentWidth * 2,
    display.actualContentHeight * 2)
  instance:setFillColor(unpack(color))
  instance.alpha = 0
  local function destroy()
    if onComplete then onComplete() end
    display.remove(instance)
  end
  transition.to(instance, {alpha = 1, time = time or 500, delay = delay or 0, transition = easing.outQuad, onComplete=destroy})
  return instance
end

-- fade from black
local function fadeIn(onComplete, time, delay)
  local color = { 0, 0, 0, 1 }
  local instance = display.newRect(
    display.contentCenterX,
    display.contentCenterY,
    display.actualContentWidth,
    display.actualContentHeight)
  instance:setFillColor(unpack(color))
  instance.alpha = 1
  local function destroy()
    if onComplete then onComplete() end
    display.remove(instance)
  end
  transition.to(instance, {alpha = 0, time = time or 500, delay = delay or 1, transition = easing.outQuad, onComplete=destroy})
  return instance
end

local function irisOut(onComplete, time, delay)
  local color = { 0, 0, 0, 1 }
  local x,y = display.contentCenterX, display.contentCenterY
  local wide = display.actualContentHeight > display.actualContentWidth and display.actualContentHeight or display.actualContentWidth
  local r = 128
  local scale = wide/r + 0.15
  local instance = display.newCircle(x,y,r)
  instance:setStrokeColor(unpack(color))
  instance:setFillColor(0,0,0,0)
  instance.strokeWidth = 0
  instance.xScale, instance.yScale = scale, scale
  instance:setFillColor(0,0,0,0)

  instance.alpha = 1
  local function destroy()
    if onComplete then onComplete() end
    display.remove(instance)
  end
  transition.to(instance, {strokeWidth = 255, time = time or 500, delay = delay or 0, transition = easing.outQuad, onCancel = destroy, onComplete=destroy})
  return instance
end

local function irisIn(onComplete, time, delay)
  local color = { 0, 0, 0, 1 }
  local x,y = display.contentCenterX, display.contentCenterY
  local wide = display.actualContentHeight > display.actualContentWidth and display.actualContentHeight or display.actualContentWidth
  local r = 128
  local scale = wide/r + 0.15
  local instance = display.newCircle(x,y,r)
  instance:setStrokeColor(unpack(color))
  instance:setFillColor(0,0,0,0)
  instance.strokeWidth = 255
  instance.xScale, instance.yScale = scale, scale

  instance.alpha = 1
  local function destroy()
    if onComplete then onComplete() end
    display.remove(instance)
  end
  transition.to(instance, {strokeWidth = 0, time = time or 500, delay = delay or 0, transition = easing.inQuad, onCancel = destroy, onComplete=destroy})
  return instance
end


function M.list()
  for k,_ in pairs(list) do
    print ("Scene:",k)
  end
end

function M.new(template, options)
  local scene = require(template)
  options = options or {}
  local name = options.name or scene.name or template

  -- does the scene already exist?
  if list[name] then
    M.remove(name, options)
  end

  -- does the scene exist?
  if not scene then
    print ("ERROR: Scene does not exist", template)
    return false
  end

  -- create scene's view
  scene.view = display.newGroup()
  local function hasView()
    return (scene.view and scene.view.numChildren)
  end
  scene.view.isVisible = false

  -- send resize event
  local function resize(event)
    if hasView() and scene.resize then
      scene:resize(event)
    end
  end
  Runtime:addEventListener("resize", resize)

  -- send enterFrame event
  local function enterFrame(event)
    if hasView() and scene.enterFrame then
      scene:enterFrame(event)
    end
    if scene._modal and scene._modal.toBack then
      scene._modal:toBack()
    end
  end
  Runtime:addEventListener("enterFrame", enterFrame)

  -- if we're modal give us a dim
  if options.modal then
    scene._modal = dim(options.dim, true)
    scene.view:insert(scene._modal)
    scene._modal:toBack()
  end

  -- send finalize event
  function scene.view:finalize(event)
    Runtime:removeEventListener("resize", resize)
    Runtime:removeEventListener("enterFrame", enterFrame)
    if scene.finalize then
      scene:finalize(event)
    end
  end
  scene.view:addEventListener("finalize")

  -- send create event
  if scene.create then
    scene:create({options = options})
  end

  -- add scene to list
  scene.name = name
  list[name] = scene

  return scene
end

function M.show(name, options)
  local scene = list[name]
  options = options or {}
  local onComplete = options.onComplete

  -- does the scene exist?
  if not scene then
    print ("ERROR: Scene does not exist", name)
    return false
  end

  if scene.resize then
    scene:resize()
  end

  if options.transition == "fade" then
    if scene.show then scene:show({phase = "began", options = options}) end
    scene.view.isVisible = true
    local function ended()
      if scene.show then scene:show({phase = "ended", options = options}) end
      if onComplete then onComplete() end
    end
    M.overlay:insert(fadeIn(ended, options.time, options.delay))
    M.overlay:toFront()
  elseif options.transition == "iris" then
    if scene.show then scene:show({phase = "began", options = options}) end
    scene.view.isVisible = true
    local function ended()
      if scene.show then scene:show({phase = "ended", options = options}) end
      if onComplete then onComplete() end
    end
    M.overlay:insert(irisIn(ended, options.time, options.delay))
    M.overlay:toFront()
  else -- no transition
    if scene.show then scene:show({phase = "began", options = options}) end
    scene.view.isVisible = true
    if scene.show then scene:show({phase = "ended", options = options}) end
    if onComplete then onComplete() end
  end

end

function M.hide(name, options)
  local scene = list[name]
  options = options or {}
  local onComplete = options.onComplete

  -- does the scene exist?
  if not scene then
    print ("ERROR: Scene does not exist", name)
    return false
  end

  if options.transition == "fade" then
    if scene.hide then scene:hide({phase = "began", options = options}) end
    local function ended()
      scene.view.isVisible = false
      if scene.hide then scene:hide({phase = "ended", options = options}) end
      if onComplete then onComplete() end
    end
    M.overlay:insert(fadeOut(ended, options.time, options.delay))
    M.overlay:toFront()
  elseif options.transition == "iris" then
    if scene.hide then scene:hide({phase = "began", options = options}) end
    local function ended()
      scene.view.isVisible = false
      if scene.hide then scene:hide({phase = "ended", options = options}) end
      if onComplete then onComplete() end
    end
    M.overlay:insert(irisOut(ended, options.time, options.delay))
    M.overlay:toFront()
  else -- no transition
    if scene.hide then scene:hide({phase = "began", options = options}) end
    scene.view.isVisible = false
    if scene.hide then scene:hide({phase = "ended", options = options}) end
    if onComplete then onComplete() end
  end

end

function M.remove(name, options)
  local scene = list[name]
  options = options or {}

  -- does the scene exist?
  if not scene then
    print ("ERROR: Scene does not exist", name)
    return false
  end
  scene.view.isVisible = false

  -- remove scene's view, should auto kick off finalize()
  display.remove(scene.view)

  -- optional send a quick destroy before removing the scene
  if scene.destroy then
    scene:destroy()
  end

  scene = nil
  list[name] = nil

  if options.collectgarbage then
    collectgarbage()
  end
end

function M.reboot(name, options)
  local scene = list[name]
  -- does the scene exist?
  if not scene then
    print ("ERROR: Scene does not exist", name)
    return false
  end

end

return M
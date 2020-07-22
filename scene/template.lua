-- Scenes: scene template

local scenes = require "scenes"
local scene = {}

-- set a more friendly name, or required filename is used
-- can be overwritten on new() with name = "instanceName"
scene.name = "template"

-- variables local to scene
local image

function scene:create(event)
  local options = event.options or {}
  local view = scene.view

  -- add addtional groups here
  scene.hud = display.newGroup()
  scene.view:insert(scene.hud)

  -- load all your sound, images, files, etc. here
  image = display.newCircle(view, 0, 0 , 128)

  print("Created scene", self.name)
end

function scene:resize(event)
  -- place all your graphics and images here
  image.x, image.y = display.contentCenterX, display.contentCenterY
  print("Resized scene", self.name)

end

function scene:show(event)
  local options = event.options or {}
  -- automatically calls resize(), start timers, game loop etc.
  if event.phase == "began" then
    print("Began showing scene", self.name)

  elseif event.phase == "ended" then
    print("Finished showing scene", self.name)
    -- you could resume here
    self:resume()
  end
end

function scene:pause()
  -- add things here that might need to pause, must be called manually
  scene.paused = true
end

function scene:resume()
  -- restart things here that might needed to pause, must be called manually
  scene.paused = false
end

function scene:enterFrame(event)
  -- called every frame

  if not scene.view.isVisible then return end
  -- if scene is hidden don't do these things

  if scene.paused then return end
  -- if scene paused don't do these things
end

function scene:hide(event)
  local options = event.options or {}
  -- called when scene gets hidden
  if event.phase == "began" then
    print("Began hiding scene", self.name)

  elseif event.phase == "ended" then
    print("Finished hiding scene", self.name)
    -- you could pause here to save resources
    self:pause()
  end
end

function scene:finalize(event)
  -- optional, gets called when scene view gets removed
  -- use scenes.remove() to safely start the process
  print("Scene finalized", self.name)

end

function scene:destroy()
  -- optional, gets called before module set to nil
  print("Scene destroyed", self.name)

end

return scene

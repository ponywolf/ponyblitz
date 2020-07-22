-- Scenes: scene template

local scenes = require "scenes"
local scene = {}

-- set a more friendly name, or required filename is used
-- can be overwritten on new() with name = "instanceName"
scene.name = "game"

-- variables local to scene
local world, hud, map

-- requirements
local composer = require "composer"
local libworld = require "scene.game.lib.pixelWorld"
local ponytiled = require "com.ponywolf.ponytiled"
local fx = require "com.ponywolf.ponyfx"
local snap = require "com.ponywolf.snap"
local json = require "json"

function scene:create(event)
  local options = event.options or {}
  local view = scene.view

  -- add addtional groups here
  scene.hud = display.newGroup()
  scene.view:insert(scene.hud)

  -- create an empty world
  world = libworld.new()
  world:reset()
  view:insert(world)


	physics.start()

  -- Load a tiled map
  local filename = system.pathForFile("scene/game/map/test.json")
  local data = json.decodeFile(filename)
  map = ponytiled.new(data, "scene/game/map")
  map.xScale, map.yScale = 0.25,0.25
  map:centerAnchor()
  --map:centerObject("camera")
	map:extend("joint")
	world.group:insert(map)

  -- create an HUD group
  hud = display.newGroup()
	scene.score = display.newText{ parent=hud, text = "HUD Group", font = "font/Kenney Future Narrow.ttf", fontSize = "32" }
	view:insert(hud)

  print("Created scene", self.name)
end

function scene:resize(event)
  -- place all your graphics and images here
  snap(scene.score, "topcenter", 16)
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

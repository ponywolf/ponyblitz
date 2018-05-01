-- Requirements
local composer = require "composer"
local libworld = require "scene.game.lib.world"
local ponytiled = require "com.ponywolf.ponytiled"
local fx = require "com.ponywolf.ponyfx"
local snap = require "com.ponywolf.snap"
local json = require "json"

-- Variables local to scene
local scene = composer.newScene()
local world, hud, map

function scene:create( event )
  local view = self.view -- add display objects to this group
  
 
  -- create an empty world
--  world = libworld.new()
--  world:reset()
--  view:insert(world)
	
	-- snap world to square
	--world:centerObj(rect) 
 
	
	physics.start()
	
  -- or load a tiled map
  local filename = system.pathForFile("scene/game/map/test.json")
  local data = json.decodeFile(filename)
  map = ponytiled.new(data, "scene/game/map")
  map:centerObject("camera")
	map:extend("pivot")
	view:insert(map)
	

  -- create an HUD group
  hud = display.newGroup()
	scene.score = display.newText{ parent=hud, text = "HUD Group", font = "RobotoMono.ttf", fontSize = "32" }
  snap(scene.score, "topcenter", 16)
	view:insert(hud)

end

local function enterFrame(event)
  local elapsed = event.time

end

local function key(event)
  local phase, name = event.phase, event.keyName
  print(phase, name)
end

function scene:show( event )
  local phase = event.phase
  if ( phase == "will" ) then
    Runtime:addEventListener("enterFrame", enterFrame)
  elseif ( phase == "did" ) then
    Runtime:addEventListener( "key", key )
  end
end

function scene:hide( event )
  local phase = event.phase
  if ( phase == "will" ) then
    Runtime:removeEventListener( "key", key )
  elseif ( phase == "did" ) then
    Runtime:removeEventListener("enterFrame", enterFrame)
  end
end

function scene:destroy( event )

end

scene:addEventListener("create")
scene:addEventListener("show")
scene:addEventListener("hide")
scene:addEventListener("destroy")

return scene
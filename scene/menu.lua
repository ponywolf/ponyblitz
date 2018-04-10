-- Requirements
local composer = require "composer"
local snap = require "com.ponywolf.snap"
local ponymenu = require "com.ponywolf.ponymenu"

-- Variables local to scene
local scene = composer.newScene()
local menu

function scene:create( event )
	local view = self.view -- add display objects to this group

	-- load sounds
	self.sounds = require "scene.game.sounds"

	-- menu listener
	local function onMenu(event)
		local phase, name = event.phase, event.name or "none"
		print (phase, name)
		if phase == "selected" then
			if name == "play" then
				composer.gotoScene("scene.game")
			elseif name == "soundon" then
				audio.volume = audio.defaultVolume
				audio.setVolume(audio.volume)  
			elseif name == "soundoff" then
				audio.volume = 0
				audio.setVolume(audio.volume)  
			elseif name == "quit" then
				native.requestExit()
			end
		end
	end

	-- create a start menu
	menu = ponymenu.new( onMenu, { align = "center", font = "scene/menu/font/RobotoMono.ttf", fontSize = 32 })
	menu:add("Play")
	menu:add("Sound Off,Sound On")
	menu:add("Quit")

	view:insert(menu)
	snap(menu)

end

local function enterFrame(event)
	local elapsed = event.time

end

function scene:show( event )
	local phase = event.phase
	if ( phase == "will" ) then
		Runtime:addEventListener("enterFrame", enterFrame)
	elseif ( phase == "did" ) then

	end
end

function scene:hide( event )
	local phase = event.phase
	if ( phase == "will" ) then

	elseif ( phase == "did" ) then
		Runtime:removeEventListener("enterFrame", enterFrame)
	end
end

function scene:destroy( event )
	audio.stop()
	for s,v in pairs( self.sounds ) do
		audio.dispose( v )
		self.sounds[s] = nil
	end
end

scene:addEventListener("create")
scene:addEventListener("show")
scene:addEventListener("hide")
scene:addEventListener("destroy")

return scene
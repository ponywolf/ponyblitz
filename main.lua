--[[

This is the main.lua file. It executes first and in this demo
is sole purpose is to set some initial visual settings and
then you execute our game or menu scene via composer.

Composer is the official scene (screen) creation and management
library in Corona SDK. This library provides developers with an
easy way to create and transition between individual scenes.

https://docs.coronalabs.com/api/library/composer/index.html 

-- ]]

local composer = require "composer"

-- Removes status bar on iOS
display.setStatusBar( display.HiddenStatusBar ) 

-- Removes bottom bar on Android 
if system.getInfo( "androidApiLevel" ) and system.getInfo( "androidApiLevel" ) < 19 then
	native.setProperty( "androidSystemUiVisibility", "lowProfile" )
else
	native.setProperty( "androidSystemUiVisibility", "immersiveSticky" ) 
end

-- reserve audio for menu and bgsound
local snd = require "com.ponywolf.ponysound"
snd:setVolume(0.5)
snd:batch("blip", "laser", "explode", "jump", "thud", "coin")
snd:loadMusic("snd/venus.wav")
snd:playMusic()

-- are we running on a simulator?
local isSimulator = "simulator" == system.getInfo( "environment" )
local isMobile = ("ios" == system.getInfo("platform")) or ("android" == system.getInfo("platform"))

-- if we are load our visual monitor that let's a press of the "F"
-- key show our frame rate and memory usage, "P" to show physics
if isSimulator then 

	-- show FPS
	local visualMonitor = require( "com.ponywolf.visualMonitor" )
	local visMon = visualMonitor:new()
	visMon.isVisible = false

	-- show/hide physics
	local function key(event)
		local phase = event.phase
		local key = event.keyName
		if phase == "up" then
			if key == "p" then
				physics.show = not physics.show
				if physics.show then 
					physics.setDrawMode( "hybrid" ) 
				else
					physics.setDrawMode( "normal" )  
				end
			elseif key == "f" then
				visMon.isVisible = not visMon.isVisible
			elseif key == "m" then
				snd:toggleVolume()       
			elseif key == "escape" then
				composer.gotoScene( "scene.menu", { params={ } } )
				composer.removeHidden()
			end
		end
	end
	Runtime:addEventListener( "key", key ) 
end

-- this module turns gamepad axis events into keyboard
-- events so we don't have to write separate code 
-- for joystick and keyboard control
require("com.ponywolf.joykey").start()

--local scanlines = require "scene.game.lib.scanlines"
--local stage = display.getCurrentStage()
--stage:insert(composer.stage)
--stage:insert(scanlines.new())

-- go to menu screen
display.setDefault("background", 0.2,0.2,0.2)
composer.gotoScene( "scene.game", { params={ } } )

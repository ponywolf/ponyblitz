--[[

This is the main.lua file. It executes first and in this demo
is sole purpose is to set some initial visual settings.

-- ]]

local device = require "com.ponywolf.device"

if device.isAndroid then
  if system.getInfo( "androidApiLevel" ) and system.getInfo( "androidApiLevel" ) < 19 then
    native.setProperty( "androidSystemUiVisibility", "lowProfile" )
  else
    native.setProperty( "androidSystemUiVisibility", "immersiveSticky" )
  end
end

if device.isiOS then -- don't turn off background music, remove status bar on iOS
  display.setStatusBar( display.HiddenStatusBar )
  native.setProperty( "prefersHomeIndicatorAutoHidden", true )
  native.setProperty( "preferredScreenEdgesDeferringSystemGestures", true )
  audio.setSessionProperty(audio.MixMode, audio.AmbientMixMode)
end

-- reserve audio for menu and bgsound
local snd = require "com.ponywolf.ponysound"
snd:setVolume(0.5)
snd:batch("blip", "laser", "explode", "jump", "thud", "coin")
snd:loadMusic("snd/venus.wav")
snd:playMusic()


-- if we are load our visual monitor that let's a press of the "F"
-- key show our frame rate and memory usage, "P" to show physics
if device.isSimulator then

  -- show FPS
  local visualMonitor = require( "com.ponywolf.visualMonitor" )
  local visMon = visualMonitor:new()
  visMon.isVisible = false

  -- show/hide physics
  local function key(event)
    local phase = event.phase
    local name = event.keyName
    if phase == "up" then
      if name == "f10" then
        physics.show = not physics.show
        if physics.show then
          physics.setDrawMode( "hybrid" )
        else
          physics.setDrawMode( "normal" )
        end
      elseif name == "`" then
        visMon.isVisible = not visMon.isVisible
      elseif name == "f12" then
        device.screenshot()
      elseif name == "escape" then
        -- quick exit
      end
    end
  end
  Runtime:addEventListener( "key", key )
end

-- this module turns gamepad axis events into keyboard
-- events so we don't have to write separate code
-- for joystick and keyboard control
require("com.ponywolf.joykey").start()


-- go to menu screen
display.setDefault("background", 0.2,0.2,0.2)

local scenes = require "scenes"
local template = scenes.new("scene.menu")
scenes.show("menu", {transition = "fade", time = 250 })


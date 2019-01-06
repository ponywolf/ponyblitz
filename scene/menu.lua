-- Requirements
local composer = require "composer"
local snap = require "com.ponywolf.snap"
local ponymenu = require "com.ponywolf.ponymenu"
local snd = require "com.ponywolf.ponysound"
local fx = require "com.ponywolf.ponyfx"

-- Variables local to scene
local scene = composer.newScene()
local menu

function scene:create( event )
  local view = self.view -- add display objects to this group

  -- menu listener
  local function onMenu(event)
    local phase, name = event.phase, event.name or "none"
    print (phase, name)
    if phase == "selected" then
      snd:play("blip")
      if name == "play" then
        fx.fadeOut(function() composer.gotoScene("scene.game") end)
      elseif name == "soundon" then
        snd:toggleVolume()
      elseif name == "soundoff" then
        snd:toggleVolume()		
      elseif name == "musicon" then
        snd:pauseMusic()
      elseif name == "musicoff" then
        snd:resumeMusic()
      elseif name == "fullscreen" then
        display.fullscreen = not display.fullscreen 
        if display.fullscreen then
          native.setProperty("windowMode", "fullscreen")
        else
          native.setProperty("windowMode", "normal")
        end  			
      elseif name == "quit" then
        native.requestExit()
      end
    end
  end

  -- create a start menu
  menu = ponymenu.new( onMenu, { align = "center", font = "RobotoMono.ttf", fontSize = 32 })
  menu:add("Play")
  menu:add("Fullscreen")
  menu:add("Sound Off,Sound On")
  menu:add("Music Off,Music On")
  menu:add("Quit")

  view:insert(menu)
  snap(menu)

  -- keys to toggle volume and music
  local function key(event)
    local phase = event.phase
    local name = event.keyName
    if phase == "up" then
    elseif name == "v" then
      snd:toggleVolume()
      if snd.volume > 0 then
        menu:set("soundoff")
      else
        menu:set("soundon")
      end
    end
  end
  Runtime:addEventListener( "key", key ) 
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

end

scene:addEventListener("create")
scene:addEventListener("show")
scene:addEventListener("hide")
scene:addEventListener("destroy")

return scene
-- Scenes: scene template

local scenes = require "scenes"
local scene = {}

-- set a more friendly name, or required filename is used
-- can be overwritten on new() with name = "instanceName"
scene.name = "menu"

-- variables local to scene
local menu

-- requirements
local snap = require "com.ponywolf.snap"
local ponymenu = require "com.ponywolf.ponymenu"
local snd = require "com.ponywolf.ponysound"
local fx = require "com.ponywolf.ponyfx"

-- preload game scene
local game = scenes.new("scene.game")

function scene:create(event)
  local options = event.options or {}
  local view = self.view -- add display objects to this group

  -- menu listener
  local function onMenu(event)
    local phase, name = event.phase, event.name or "none"
    print (phase, name)
    if phase == "selected" then
      snd:play("blip")
      if name == "play" then
        local function go()
          scenes.show("game", {transition = "fade", time = 1000 })
        end
        scenes.hide("menu", {transition = "fade", time = 1000, onComplete = go })
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
  menu = ponymenu.new( onMenu, { align = "center", font = "font/Kenney Pixel Square.ttf", fontSize = 32 })
  menu:add("Play")
  menu:add("Fullscreen")
  menu:add("Sound Off,Sound On")
  menu:add("Music Off,Music On")
  menu:add("Quit")

  view:insert(menu)

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

function scene:resize(event)
  -- place all your graphics and images here
  snap(menu)
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

-- ponywolf pixel particles

-- Date: Dec 28, 2019
-- Updated: Dec 28, 2019

local color = require "com.ponywolf.ponycolor"

local M = {}
local json = require "json"

local maxFrames = 180
local bounce = 0.75
local friction = 0.975
local minimum = 0.25
local gravity = 3

local rnd = math.random

function M.explode(obj, radius)
  if not obj.contentBounds then
    print("WARNING: Object not found")
    return false
  end
  local parent = obj.parent or display.getCurrentStage()
  radius = (radius or 16) * 2
  -- the boom

  local boom = display.newImageRect(parent, "particles/32px.png",radius,radius)
  boom.x, boom.y = obj.x, obj.y - 4

  -- Kill the particle when done.
  local function die()
    display.remove(boom)
  end

  transition.to(boom, {
      time = 166, -- In 1.0 seconds.
      xScale = 1.25, -- Shrink.
      yScale = 1.25,
      y = boom.y - 4,
      transition = easing.outQuad,
      onComplete = die, -- And die.
    })

  for i = 1, 16 do
    local flak = display.newImageRect(parent, "particles/8px.png",6,6)
    flak.x, flak.y = obj.x, obj.y - 4
    local size = 0.15 + rnd()/2

    -- Kill the particle when done.
    local function die()
      display.remove(flak)
    end

    local function shrink()
      if flak then
        transition.to(flak, {
            time = 333, -- In 1.0 seconds.
            xScale = 0.1, -- Shrink.
            yScale = 0.1,
            y = flak.y - 16 * rnd(),
            transition = easing.outQuad,
            onComplete = die, -- And die.
          })
      end
    end

    -- Start a transition
    local angle = math.random(0,360)
    local dist = math.random(radius*0.75, radius*1.25)/2
    local dx, dy = math.cos(math.deg(angle)), math.sin(math.deg(angle))
    transition.to(flak, {
        delta = true, -- Move from current location.
        delay = 33,
        time = 333,
        x = dx * dist,
        y = dy * dist - 4,
        xScale = size,
        yScale = size,
        transition = easing.outExpo,
        onComplete = shrink,
      })
  end
end

function M.fire(obj)
  if not obj.contentBounds then
    print("WARNING: Object not found")
    return false
  end

  local parent = obj.parent
  local fire = display.newImageRect(parent, "particles/8px.png", 8,8)
  fire:toBack()
  fire.x, fire.y = obj.x + math.random(-2,2), obj.y + math.random(-2,2)
  local size = 0.9
  --smoke.blendMode = "add"
  fire:setFillColor(1,0,0,1)

  -- Kill the particle when done.
  local function die()
    display.remove(fire)
  end

  -- Start a transition.
  transition.to(fire, {
      delta = true, -- Move from current location.
      time = 1666, -- In 1.0 seconds.
      x = rnd(-2, 2), -- Wiggle.
      y = rnd(-24, -16), -- Go up.
      xScale = -size, -- Shrink.
      yScale = -size,
      transition = easing.outQuad,
      onComplete = die, -- And die.
    })
end


function M.smoke(obj)
  if not obj.contentBounds then
    print("WARNING: Object not found")
    return false
  end

  local parent = obj.parent
  local smoke = display.newImageRect(parent, "particles/12px.png", 8,8)
  smoke.anchorY = 1
  smoke:toBack()
  smoke.x, smoke.y = obj.x, obj.y + 8
  local size = 0.5 + rnd()
  --smoke.blendMode = "add"

  -- Kill the particle when done.
  local function die()
    display.remove(smoke)
  end

  local function shrink()
    transition.to(smoke, {
        time = 333, -- In 1.0 seconds.
        xScale = 0.1, -- Shrink.
        yScale = 0.1,
        y = smoke.y - 3 * rnd(),
        onComplete = die, -- And die.
      })
  end

  -- Start a transition.
  transition.to(smoke, {
      delta = true, -- Move from current location.
      time = 666, -- In 1.0 seconds.
      x = rnd(-4, 4), -- Wiggle.
      y = rnd(-4, -2), -- Go up.
      xScale = size, -- Shrink.
      yScale = size,
      transition = easing.outQuad,
      onComplete = shrink, -- And die.
    })
end

function M.emitter(x,y, options)
  options = options or {}
  local instance = display.newGroup()
  local particles = {}
  local maxParticles = 0


  function instance:spurt(startAngle, endAngle, startSpeed, endSpeed, floor)
    local angle = math.random(startAngle, endAngle)
    local speed = math.random(math.floor(startSpeed * 256), math.floor(endSpeed * 256))/256
    local dx, dy = math.cos(math.rad(angle)) * speed, math.sin(math.rad(angle)) * speed
    particles[#particles+1] = display.newImageRect(self.parent, "particles/4px.png", 6, 6)
    particles[#particles].x, particles[#particles].y = self.x, self.y
    particles[#particles].ax, particles[#particles].ay = self.x, self.y
    particles[#particles]:setFillColor(unpack(color.hex2rgb(options.color or "FFFFFF")))
    particles[#particles].dx, particles[#particles].dy = dx, dy
    particles[#particles].floor = floor or options.floor or 9999
    --print("Open",#particles)
    maxParticles = math.max(#particles,maxParticles)
  end

  local function enterFrame()
    if not (instance and instance.x and instance.y) then
      instance:finalize()
    end
    for i = 1, #particles do
      -- if our instance went away (got this error when I died and tried to reset)
      if not instance or not instance.y then
        return
      end
        
      if particles[i] then
        particles[i].dx = particles[i].dx * friction
        particles[i].dy = particles[i].dy * friction
        -- frames
        particles[i].frame = (particles[i].frame or 0) + 1
        
        -- bounce?
        local distFromFloor = particles[i].floor - (particles[i].ay - instance.y)
        if distFromFloor < -minimum then
          particles[i].ay = instance.y + particles[i].floor
          particles[i].dy = -bounce * (particles[i].dy + 2 * (options.gravity or gravity))
        end
        -- move w/ gravity & friction
        particles[i].dx = (math.abs(particles[i].dx) > minimum) and particles[i].dx or 0
        particles[i].dy = (math.abs(particles[i].dy) > minimum) and particles[i].dy or 0
        particles[i].ax, particles[i].ay = particles[i].ax + particles[i].dx, particles[i].ay + particles[i].dy + (options.gravity or gravity)
        -- set on pixel
        particles[i].x, particles[i].y = math.floor(particles[i].ax + 0.5), math.floor(particles[i].ay + 0.5)
        -- delete after maxframes
        if particles[i].frame > maxFrames then
          --print("Removed",i)
          display.remove(particles[i])
          particles[i] = nil
          if i > 0 and i == maxParticles then
            display.remove(instance)
          end
        elseif particles[i].frame > maxFrames - 60 then
          particles[i].alpha = (maxFrames - particles[i].frame) / 60
        end
      end
    end
  end

  function instance:finalize()
    Runtime:removeEventListener("enterFrame", enterFrame)
  end

  --instance.isVisible = false
  Runtime:addEventListener("enterFrame", enterFrame)
  return instance
end

function M.critical(object)
  local blood = M.emitter(0, 0)
  object.parent:insert(blood)
  blood.x, blood.y = object.x, object.y - 4
  for i = 1, 16 do
    blood:spurt(270-15, 270+15, 3, 5, math.random(6,10))
  end
  return blood
end

return M
-- tiled Plugin template

-- Use this as a template to extend a tiled object with functionality
local M = {}

function M.new(instance, map)

  if not instance then error("ERROR: Expected display object") end
  print ("Found pivot: ",instance.name, " connects ", instance.bodyA,  "to", instance.bodyB)
  local bodyA = map:findObject(instance.bodyA)
  local bodyB = map:findObject(instance.bodyB)
  instance.joint = physics.newJoint(instance.joint or "pivot", bodyA, bodyB, instance.x, instance.y)
  instance.isSensor = true
  instance.isVisible = false -- hide rect placeholder
  instance.alpha = 0 -- hide rect placeholder      
  return instance
end

return M
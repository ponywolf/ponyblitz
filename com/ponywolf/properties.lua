local M = {}

function M.get(object, properties)
  local values = {}
  for _,v in pairs(properties) do
    values[v] = object[v]
    --print("Properties: getting", v , object[v])
  end
  return values
end

function M.set(object, values)
  for k,v in pairs(values) do
    object[k] = v or object[k]
    --print("Properties: setting", k ,v)
  end
  return object
end

return M
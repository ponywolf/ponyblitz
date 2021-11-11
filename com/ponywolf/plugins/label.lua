-- smart label

local M = {}
local renderSteps = 0.5

local function decodeTiledColor(hex)
  hex = hex or "#FF888888"
  hex = hex:gsub("#","")
  local function hexToFloat(part)
    part = part or "00"
    part = part == "" and "00" or part
    return tonumber("0x".. (part or "00")) / 255
  end
  local a, r, g, b =  hexToFloat(hex:sub(1,2)), hexToFloat(hex:sub(3,4)), hexToFloat(hex:sub(5,6)), hexToFloat(hex:sub(7,8)) 
  return r, g, b, a
end

local function decodeStrokeColor(hex)
  hex = hex or "#FF888888"
  hex = hex:gsub("#","")
  local function hexToFloat(part)
    part = part or "00"
    part = part == "" and "00" or part
    return tonumber("0x".. (part or "00")) / 255
  end
  local a, r, g, b =  hexToFloat(hex:sub(1,2)), hexToFloat(hex:sub(3,4)), hexToFloat(hex:sub(5,6)), hexToFloat(hex:sub(7,8)) 
  local color = {
    highlight = { r=r, g=g, b=b },
    shadow =  { r=r, g=g, b=b },
  }
  return color
end

function M.new(instance)
  if not instance then error("ERROR: Expected display object") end  

  -- remember inital object
  local tiledObj = instance

  -- set defaults
  local text = tiledObj.text or " "
  text = text:gsub("|","\n")
  local font = tiledObj.font or native.systemFont
  local size = tiledObj.size or 20
  local stroked = tiledObj.stroked
  local strokeColor = tiledObj.strokeColor or "FF000000"
  local align = tiledObj.align or "center"
  local color = tiledObj.color or "FFFFFFFF"
  local params = { parent = tiledObj.parent,
    x = tiledObj.x, y = tiledObj.y, strokeColor = strokeColor, color = color,
    text = text, font = font, fontSize = size, strokeWidth = tiledObj.labelStrokeWidth or 1,
    align = align, width = tiledObj.width } 

  if stroked then
    instance = display.newEmbossedText(params)
    instance:setTextColor(decodeTiledColor(color))
    instance:setEmbossColor(decodeStrokeColor(strokeColor))    
  else
    instance = display.newText(params)
    instance:setTextColor(decodeTiledColor(color))
  end
  function instance:update(text) instance.text = text end  

-- push the rest of the properties
  instance.rotation = tiledObj.rotation 
  instance.name = tiledObj.name 
  instance.type = tiledObj.type
  instance.alpha = tiledObj.alpha 

  if not tiledObj.keepInstance then
    display.remove(tiledObj)
  end

  return instance
end

return M
-- ponyswap

-- Pixel Color Swapping via Shader

local M = {}

local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
-- By default, the group is "custom"
--kernel.group = "custom"
kernel.name = "multiswap"

-- Expose effect parameters using vertex data
kernel.uniformData = {
  {
    name = "keys",
    default = {
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0
    },
    min = {
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0
    },
    max = {
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0
    },
    type="mat4",
    index = 0, -- u_UserData0
  },
  {
    name = "colors",
    default = {
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0
    },
    min = {
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0
    },
    max = {
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0
    },
    type="mat4",
    index = 1, -- u_UserData1
  },
  {
    name = "keys2",
    default = {
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0
    },
    min = {
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0
    },
    max = {
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0
    },
    type="mat4",
    index = 2, -- u_UserData2
  },
  {
    name = "colors2",
    default = {
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0
    },
    min = {
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0
    },
    max = {
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0
    },
    type="mat4",
    index = 3, -- u_UserData3
  },
}

kernel.fragment = [[

uniform P_COLOR mat4 u_UserData0; // keys
uniform P_COLOR mat4 u_UserData1; // colors
uniform P_COLOR mat4 u_UserData2; // keys
uniform P_COLOR mat4 u_UserData3; // colors

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_COLOR vec4 texColor = texture2D( CoronaSampler0, texCoord );
  for(int i = 0; i < 4; i++)
    {
    P_COLOR vec4 keys = u_UserData0[i];
    P_COLOR vec4 colors = u_UserData1[i];
    if ((abs(texColor[0] - keys[0]) < 0.01) && (abs(texColor[1] - keys[1]) < 0.01) && (abs(texColor[2] - keys[2]) < 0.01))
      {
        texColor = colors;
      }
    }
  for(int i = 0; i < 4; i++)
    {
    P_COLOR vec4 keys2 = u_UserData2[i];
    P_COLOR vec4 colors2 = u_UserData3[i];
    if ((abs(texColor[0] - keys2[0]) < 0.01) && (abs(texColor[1] - keys2[1]) < 0.01) && (abs(texColor[2] - keys2[2]) < 0.01))
      {
        texColor = colors2;
      }
    }
  return CoronaColorScale(texColor);
}
]]

graphics.defineEffect( kernel )

-- HEX to RGB

local function hex2rgb(hex)
  local function hex2float(num,a,b)
    return tonumber("0x"..hex:sub(a,b)) / 255
  end
  hex = hex:gsub("#","")
  if string.len(hex) == 3 then
    return { hex2float(hex,1,1) * 17, hex2float(hex,2,2) * 17, hex2float(hex,3,3) * 17, 1}
  elseif string.len(hex) == 6 then
    return { hex2float(hex,1,2), hex2float(hex,3,4), hex2float(hex,5,6), 1 }
  elseif string.len(hex) == 8 then
    return { hex2float(hex,1,2), hex2float(hex,3,4), hex2float(hex,5,6), hex2float(hex,7,8) }
  end
end

function M.swap(object, keys, colors, keys2, colors2)

  if not object and object.fill then
    print("WARNING: No image to swap")
    return false
  end

  if not keys or not #keys then
    print("WARNING: No colors to swap")
    return false
  end

  local matKeys, matColors, index = {}, {}, 0
  for i = 1, #keys do --convert from HEX to RGB
    local k = hex2rgb(keys[i])
    local v = hex2rgb(colors[i])
    for j = 1, 4 do
      index=index+1
      matKeys[index], matColors[index] = k[j], v[j]
    end
  end

  local matKeys2, matColors2 = {}, {}
  keys2, colors2 = keys2 or keys, colors2 or colors
  index = 0
  for i = 1, #keys2 do --convert from HEX to RGB
    local k = hex2rgb(keys2[i])
    local v = hex2rgb(colors2[i])
    for j = 1, 4 do
      index=index+1
      matKeys2[index], matColors2[index] = k[j], v[j]
    end
  end

  object.fill.effect = "filter.custom.multiswap"
  object.fill.effect.keys = matKeys
  object.fill.effect.colors = matColors
  object.fill.effect.keys2 = matKeys2
  object.fill.effect.colors2= matColors2
end

setmetatable(M, { __call = function(_, ...) return M.swap(...) end })

return M
-- 4 color pixel swapping

-- USAGE:
-- require ("multiswap')

--local object = display.newImage("image.png")

--object.fill.effect = "filter.custom.multiswap"
--object.fill.effect.keys = {
--  213/255,  95/255,  96/255, 1,
--  141/255,  76/255, 101/255, 1,
--  218/255, 177/255, 132/255, 1,
--  160/255, 125/255, 121/255, 1
--}
--object.fill.effect.colors = {
--  243/255, 133/255,  11/255, 1,
--  186/255, 102/255,  10/255, 1,
--  102/255,  63/255,  21/255, 1,
--   92/255,  50/255,   4/255, 1
--}

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
}

kernel.fragment = [[

uniform P_COLOR mat4 u_UserData0; // keys
uniform P_COLOR mat4 u_UserData1; // colors

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_COLOR vec4 texColor = texture2D( CoronaSampler0, texCoord );
  for(int i = 0; i < 4; i++)
    {
    P_COLOR vec4 keys = u_UserData0[i];
    P_COLOR vec4 colors = u_UserData1[i];
    if ( texColor[0] == keys[0] && texColor[1] == keys[1] && texColor[2] == keys[2] )
      {
        texColor = colors;
        break;
      }
    }
  return CoronaColorScale(texColor);
}
]]

graphics.defineEffect( kernel )

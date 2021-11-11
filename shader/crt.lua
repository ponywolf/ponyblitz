-- Shader tewmplate module

-- Building this module with some helpful info
-- and info to port ShaderToy effects

local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.name = "crt" -- shader name goes here

-- set if shader code uses time environment variable CoronaTotalTime
kernel.isTimeDependent = false

kernel.vertexData =
{
  {
  name = "warp",
  default = 0.333,
  min = 0.0,
  max = 4.0,
  index = 0,  -- This corresponds to "CoronaVertexUserData.x"
 },
 {
  name = "scan",
  default = 0.333,
  min = 0.0,
  max = 2.0,
  index = 1,  -- This corresponds to "CoronaVertexUserData.y"
 },
}


--kernel.vertex =
--[[

--P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
--{

--}

--]]

kernel.fragment =
-- Function for void mainImage( out vec4 fragColor, in vec2 fragCoord );
[[

float warp = CoronaVertexUserData.x; // simulate curvature of CRT monitor
float scan = CoronaVertexUserData.y; // simulate darkness between scanlines

P_COLOR vec4 FragmentKernel( P_UV vec2 fragCoord )
{
  // squared distance from center
  P_UV vec2 uv = fragCoord;
  P_UV vec2 dc = abs(0.5-uv);
  dc *= dc;

  // warp the fragment coordinates
  uv.x -= 0.5; uv.x *= 1.0+(dc.y*(0.3*warp)); uv.x += 0.5;
  uv.y -= 0.5; uv.y *= 1.0+(dc.x*(0.4*warp)); uv.y += 0.5;

  // sample inside boundaries, otherwise set to black
  if (uv.y > 1.0 || uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0)
    {
      return CoronaColorScale(vec4(0.0,0.0,0.0,1.0));
    }
  else
    {
      // determine if we are drawing in a scanline
      float apply = abs(sin(fragCoord.y / CoronaTexelSize.y)*0.5*scan);
      // sample the texture
      return CoronaColorScale(vec4(mix(texture2D(CoronaSampler0,uv).rgb,vec3(0.0),apply),1.0));
    }
}

]]

graphics.defineEffect( kernel )

return kernel
-- Shader tewmplate module

-- Building this module with some helpful info
-- and info to port ShaderToy effects

local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.name = "crt" -- shader name goes here

-- set if shader code uses time environment variable CoronaTotalTime
kernel.isTimeDependent = true

--kernel.vertex =
--[[

--P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
--{

--}

--]]

kernel.vertexData =
{
  {
  name = "bend",
  default = 4,
  min = 1,
  max = 10,
  index = 0,  -- This corresponds to "CoronaVertexUserData.x"
 },
 {
  name = "vignetteSize",
  default = 2,
  min = 0,
  max = 10,
  index = 1,  -- This corresponds to "CoronaVertexUserData.y"
 },
 {
  name = "noise",
  default = 0.015,
  min = 0,
  max = 1,
  index = 2,  -- This corresponds to "CoronaVertexUserData.z"
 },
 {
  name = "chroma",
  default = 0.0025,
  min = 0,
  max = 1,
  index = 3,  -- This corresponds to "CoronaVertexUserData.w"
 },
}

kernel.fragment =
-- Function for void mainImage( out vec4 fragColor, in vec2 fragCoord );
[[

//P_DEFAULT vec4 CoronaVertexUserData;

P_UV vec2 buldge(vec2 uv, float bend)
{
 uv -= 0.5;
 uv *= 2.5;
 uv.x *= 1. + pow(abs(uv.y)/bend, 2.);
 uv.y *= 1. + pow(abs(uv.x)/bend, 2.);

 uv /= 2.5;
 return uv + .5;
 }

P_DEFAULT float vignette(vec2 uv, float size, float smoothness, float edgeRounding)
{
 uv -= .5;
 uv *= size;
 float amount = sqrt(pow(abs(uv.x), edgeRounding) + pow(abs(uv.y), edgeRounding));
 amount = 1. - amount;
 return smoothstep(0., smoothness, amount);
}

P_DEFAULT float scanline(vec2 uv, float lines, float speed)
{
 return sin(uv.y * lines + CoronaTotalTime * speed);
}

P_DEFAULT float random(vec2 uv)
{
 return fract(sin(dot(uv, vec2(15.5151, 42.2561))) * 12341.14122 * sin(CoronaTotalTime * 0.03));
}

P_DEFAULT float noise(vec2 uv)
{
 P_UV vec2 i = floor(uv);
 P_UV vec2 f = fract(uv);

 P_RANDOM float a = random(i);
 P_RANDOM float b = random(i + vec2(1.,0.));
 P_RANDOM float c = random(i + vec2(0., 1.));
 P_RANDOM float d = random(i + vec2(1.));

 P_UV vec2 u = smoothstep(0., 1., f);

 return mix(a,b, u.x) + (c - a) * u.y * (1. - u.x) + (d - b) * u.x * u.y;
}

P_COLOR vec4 FragmentKernel( P_UV vec2 fragCoord )
{
 P_UV vec2 uv = fragCoord; //CoronaTexelSize.xy;

 P_UV vec2 crt_uv = buldge(uv, 11. - CoronaVertexUserData.x);

 float s1 = scanline(uv, 400., -10.);
 float s2 = scanline(uv, 40., -3.);

 P_COLOR vec4 col;
 col.r = texture2D(CoronaSampler0, crt_uv + vec2(0., -CoronaVertexUserData.w)).r;
 col.g = texture2D(CoronaSampler0, crt_uv + vec2(CoronaVertexUserData.w,0.)).g;
 col.b = texture2D(CoronaSampler0, crt_uv + vec2(0., -CoronaVertexUserData.w)).b;
 col.a = texture2D(CoronaSampler0, crt_uv).a;

 col = mix(col, vec4(s1 + s2), 0.005);

 return CoronaColorScale(mix(col, vec4(noise(uv * 75.)), CoronaVertexUserData.z) * vignette(uv, CoronaVertexUserData.y, .6, 8.));
}

]]

graphics.defineEffect( kernel )

return kernel
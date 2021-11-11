-- Shader tewmplate module

-- Building this module with some helpful info
-- and info to port ShaderToy effects

local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.name = "static" -- shader name goes here

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
  name = "noise",
  default = 4,
  min = 1,
  max = 10,
  index = 0,  -- This corresponds to "CoronaVertexUserData.x"
 },
}

kernel.fragment =
-- Function for void mainImage( out vec4 fragColor, in vec2 fragCoord );
[[

//P_DEFAULT vec4 CoronaVertexUserData;

P_DEFAULT float noise(vec2 pos, float evolve) {
    
    // Loop the evolution (over a very long period of time).
    P_DEFAULT float e = fract((evolve*0.01));
    
    // Coordinates
    P_DEFAULT float cx  = pos.x*e;
    P_DEFAULT float cy  = pos.y*e;
    
    // Generate a "random" black or white value
    return fract(23.0*fract(2.0/fract(fract(cx*2.4/cy*23.0+pow(abs(cy/22.4),3.3))*fract(cx*evolve/pow(abs(cy),0.050)))));
}


P_COLOR vec4 FragmentKernel( P_UV vec2 fragCoord )
{

    // Increase this number to test performance
    int intensity = 1;
    
    vec3 color;
    for (int i = 0; i < intensity; i++)
        {
        // Generate a black to white pixel
        color = vec3(noise(fragCoord,CoronaTotalTime));
        }
	
    // Output to screen
    return CoronaColorScale(vec4(color,1.0));
}


]]

graphics.defineEffect( kernel )

return kernel
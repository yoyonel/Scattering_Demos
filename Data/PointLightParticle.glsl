#include "Common.glsl"

uniform mat4 g_lightToWorld;
uniform mat4 g_worldToLight;

uniform vec4 g_lightPos;
uniform vec4 g_lightCol;
uniform float g_scatteringCoefficient;

uniform sampler2D g_noiseTexture;

void main()
{
	vec3 surfacePos = gl_TexCoord[0].xyz;
	vec3 surfaceNormal = gl_TexCoord[1].xyz;
	vec3 cameraPos = gl_ModelViewMatrixInverse[3].xyz;
	vec3 lightPos = g_lightToWorld[3].xyz;

	vec3 dir = surfacePos - cameraPos;
	float l = length(dir);
	dir /= l;

	// calculate in-scattering contribution
	vec3 scatter = g_lightCol.xyz * vec3(0.2, 0.5, 0.8) * InScatter(cameraPos + dir * (l-1.0), dir, lightPos, 2.0) * g_scatteringCoefficient * 0.5;
	
	vec3 noise = SrgbToLinear(texture2D( g_noiseTexture, gl_TexCoord[2].xy).xxx);
	scatter *= noise;

	float specularExponent = 15.0;
	float specularIntensity = 0.02;

	vec3 r = LinearToSrgb(g_lightCol.xyz * scatter);

	gl_FragColor = vec4(r, 1.0);	
}
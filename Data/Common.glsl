#version 120

#define saturate(x) clamp(x, 0.0, 1.0)
#define kPi 3.1415926535897

vec3 LinearToSrgb(vec3 rgb)
{
	return pow(rgb, vec3(1.0/2.2));
}

vec3 SrgbToLinear(vec3 rgb)
{
	return pow(rgb, vec3(2.2));
}

float LinearToSrgb(float rgb)
{
	return pow(rgb, float(1.0/2.2));
}

float SrgbToLinear(float rgb)
{
	return pow(rgb, float(2.2));
}

vec3 ToneMap(vec3 rgb)
{
	// simple Reinhard like tone mapping
	float l = dot(rgb, vec3(0.212671, 0.715160, 0.072169));

	return rgb / (l + 1.0);
}

float CalculateShadowFactor(sampler2DShadow texDepth, vec3 uvw, const int samples)
{
	// Poisson disc
	vec2 vTaps[12] = vec2[] (vec2(-0.326212,-0.40581),vec2(-0.840144,-0.07358),
							 vec2(-0.695914,0.457137),vec2(-0.203345,0.620716),
							 vec2(0.96234,-0.194983),vec2(0.473434,-0.480026),
							 vec2(0.519456,0.767022),vec2(0.185461,-0.893124),
							 vec2(0.507431,0.064425),vec2(0.89642,0.412458),
							 vec2(-0.32194,-0.932615),vec2(-0.791559,-0.59771) );

	float s = 0.0;
	float radius = 0.002;

	for (int i=0; i < 12; i++)
	{
		s += shadow2D(texDepth, vec3(uvw.xy + vTaps[i]*radius, uvw.z)).r;

	}

	s /= samples;

	return s;
}

void SolveQuadratic(float a, float b, float c, out float minT, out float maxT)
{
	float discriminant = b*b - 4.0*a*c;

	if (discriminant < 0.0)
	{
		// no real solutions so return a degenerate result
		maxT = 0.0;
		minT = 0.0;
		return;
	}

	// numerical receipes 5.6 (this method ensures numerical accuracy is preserved)
	float t = -0.5 * (b + sign(b)*sqrt(discriminant));
	float closestT = t / a;
	float furthestT = c / t;

	if (closestT > furthestT)
	{	
		minT = furthestT;
		maxT = closestT;		
	}
	else
	{
		minT = closestT;
		maxT = furthestT;
	}
}

float InScatter(vec3 start, vec3 dir, vec3 lightPos, float d)
{
	// calculate quadratic coefficients a,b,c
	vec3 q = start - lightPos;

	float b = dot(dir, q);
	float c = dot(q, q);

	// evaluate integral
	float s = 1.0f / sqrt(c - b*b);

	float l = s * (atan( (d + b) * s) - atan( b*s ));

	return l;	
}

// simple diffuse + blinn phong lighting model 
void Li(vec3 surfacePos, vec3 surfaceNormal, vec3 lightPos, vec3 eyePos, float specularPower, out float diffuse, out float specular)
{
	vec3 l = lightPos-surfacePos;
	vec3 e = normalize(eyePos-surfacePos);

	float d = length(l);
	l /= d;

	// half vector
	vec3 h = normalize(e+l);
	
	diffuse = saturate(dot(surfaceNormal, l)) / (d*d);
	specular = pow(saturate(dot(h,surfaceNormal)), specularPower);
}
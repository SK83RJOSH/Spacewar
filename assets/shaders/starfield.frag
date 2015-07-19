#define PI 3.14159265358979323846

uniform float timer;

float rand(vec2 c)
{
	return fract(sin(dot(c.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float noise(vec2 p, float freq )
{
	vec2 ij = floor(p/freq);
	vec2 xy = mod(p,freq)/freq;

	xy = .5*(1.-cos(PI*xy));

	float a = rand((ij+vec2(0.,0.)));
	float b = rand((ij+vec2(1.,0.)));
	float c = rand((ij+vec2(0.,1.)));
	float d = rand((ij+vec2(1.,1.)));
	float x1 = mix(a, b, xy.x);
	float x2 = mix(c, d, xy.x);

	return mix(x1, x2, xy.y);
}

float pNoise(vec2 p, int res)
{
	float persistance = .5;
	float n = 0.;
	float normK = 0.;
	float f = 4.;
	float amp = 1.;

	int iCount = 0;

	for (int i = 0; i<50; i++){
		n+=amp*noise(p, f);
		f*=2.;
		normK+=amp;
		amp*=persistance;
		if (iCount == res) break;
		iCount++;
	}

	return pow(n / normK, 4);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
	float noiseSample = pNoise(texture_coords * 1200.0 + timer, 1);
	float noiseSample2 = pNoise(texture_coords * 2400.0 + timer, 1);

	noiseSample *= noiseSample2;
	noiseSample = 1.0 - step(noiseSample, 0.2);
	noiseSample *= sin(dot(texture_coords, vec2(1, 1)) * timer) * 0.25 + 0.75;

	if (noiseSample == 0)
	{
		float noiseSample3 = pNoise(texture_coords * 15 + (timer / 6), 1);
		float noiseSample4 = pNoise(texture_coords * 20 - vec2(timer / 4, -timer / 4), 1) * 0.2;

		return vec4((vec3(noiseSample3 * 0.16, noiseSample3 * 0.06, noiseSample3 * 0.16) +
					 vec3((1 - noiseSample3) * 0.06, (1 - noiseSample3) * 0.1, (1 - noiseSample3) * 0.16) -
					 noiseSample4) * 0.5, 1);
	}

	return vec4(noiseSample, noiseSample, noiseSample, 1);
}

#define PI 3.14159265358979323846

uniform vec2 canvas_size;
uniform bool horizontal;
uniform float blur_amount;
uniform float blur_scale;
uniform float blur_strength;

float gaussian(float x, float deviation)
{
	return (1.0 / sqrt(2.0 * PI * deviation)) * exp(-((x * x) / (2.0 * deviation)));
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
	vec2 multiply_vector = horizontal ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
	vec4 diffuse_color = vec4(0.0);
	vec4 texture_color = vec4(0.0);

	float strength = 1.0 - blur_strength;
	float half_blur = blur_amount * 0.5;
	float deviation = half_blur * 0.35;

	deviation *= deviation;

	// NOTE: This best works with mirrored repeat as your texture wrapping mode, color bleeding will occur around edges otherwise
	for(int i = 1; i < blur_amount; ++i)
	{
		float offset = float(i) - half_blur;
		vec2 coords = texture_coords + (((offset / canvas_size) * blur_scale) * multiply_vector);

		texture_color = texture2D(texture, coords) * gaussian(offset * strength, deviation);
		diffuse_color += texture_color;
	}

	return diffuse_color;
}

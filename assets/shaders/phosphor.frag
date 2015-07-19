vec3 to_focus(float pixel)
{
	pixel = mod(pixel + 3.0, 3.0);

	if (pixel >= 2.0) // Blue
		return vec3(pixel - 2.0, 0.0, 3.0 - pixel);
	else if (pixel >= 1.0) // Green
		return vec3(0.0, 2.0 - pixel, pixel - 1.0);
	else // Red
		return vec3(1.0 - pixel, pixel, 0.0);
}

vec2 distort(vec2 p)
{
	float theta = atan(p.y, p.x);
	float radius = length(p);

	radius = pow(radius, 1.1);

	p = ((1 - abs(p)) * p) + (abs(p) * radius * vec2(cos(theta), sin(theta)));

	return 0.5 * (p + 1.0);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
	// Uncomment to warp phosphor effect
	// vec2 screen_size = screen_coords / texture_coords;

	texture_coords = distort((texture_coords - 0.5) * 2);
	// screen_coords = screen_size * texture_coords;

	float intensity_mod = mod(screen_coords.y * screen_coords.x, 2.0);
	float intensity = exp(-0.2 * intensity_mod);

	vec2 one_x = vec2(texture_coords.x / screen_coords.x, 0);

	vec3 diffuse_color = texture2D(texture, texture_coords.xy - 0.0 * one_x).rgb;
	vec3 diffuse_color_prev = texture2D(texture, texture_coords.xy - 1.0 * one_x).rgb;
	vec3 diffuse_color_prev_prev = texture2D(texture, texture_coords.xy - 2.0 * one_x).rgb;

	float pixel_x = screen_coords.x;

	vec3 focus = to_focus(pixel_x - 0.0);
	vec3 focus_prev = to_focus(pixel_x - 1.0);
	vec3 focus_prev_prev = to_focus(pixel_x - 2.0);

	vec3 result =
		0.8 * diffuse_color * focus +
		0.6 * diffuse_color_prev * focus_prev +
		0.3 * diffuse_color_prev_prev * focus_prev_prev;

	result = 2.3 * pow(result, vec3(1.4));

	return vec4(intensity * result * (step(texture_coords.x, 1.0) * step(texture_coords.y, 1.0) * step(0.0, texture_coords.x) * step(0.0, texture_coords.y)), 1.0);
}

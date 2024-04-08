shader_type canvas_item;

uniform vec4 red_color : source_color = vec4(1.0);
uniform vec4 green_color : source_color = vec4(1.0);
uniform vec4 blue_color : source_color = vec4(1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (COLOR.a > 0.1 && !(COLOR.r == COLOR.g && COLOR.g == COLOR.b))
	{
		vec3 strength = vec3(.0, .0, .0);
		if (COLOR.r > 0.0)
		{
			strength.r = COLOR.r / (1.0 + COLOR.g + COLOR.b);
		}
		if (COLOR.g > 0.0)
		{
			strength.g = COLOR.g / (COLOR.r + 1.0 + COLOR.b);
		}
		if (COLOR.b > 0.0)
		{
			strength.b = COLOR.b / (COLOR.r + COLOR.g + 1.0);
		}
		COLOR = vec4((red_color.rgb * strength.r) + (green_color.rgb * strength.g) + (blue_color.rgb * strength.b), 1.0);
	}
}

shader_type canvas_item;

uniform vec4 red_color : source_color = vec4(1.0);
uniform vec4 green_color : source_color = vec4(1.0);
uniform vec4 blue_color : source_color = vec4(1.0);

uniform bool colder_shadows = true;

void fragment() {
	if (COLOR.a > 0.1 && !(COLOR.r == COLOR.g && COLOR.g == COLOR.b))
	{
		vec3 strength = vec3(.0, .0, .0);
		vec3 localStrength = vec3(1.0, 1.0, 1.0);
		if (COLOR.r > 0.0)
		{
			strength.r = COLOR.r / (1.0 + COLOR.g + COLOR.b);
			localStrength.r = COLOR.r / 1.0;
		}
		if (COLOR.g > 0.0)
		{
			strength.g = COLOR.g / (COLOR.r + 1.0 + COLOR.b);
			localStrength.g = COLOR.g / 1.0;
		}
		if (COLOR.b > 0.0)
		{
			strength.b = COLOR.b / (COLOR.r + COLOR.g + 1.0);
			localStrength.b = COLOR.b / 1.0;
		}
		vec3 red_component = red_color.rgb * strength.r;
		vec3 green_component = green_color.rgb * strength.g;
		vec3 blue_component = blue_color.rgb * strength.b;
		if (colder_shadows)
		{
			red_component.b += 0.5 * red_component.b * (1.0 - localStrength.r);
			red_component.r -= 0.5 * red_component.r * (1.0 - localStrength.r);
			
			green_component.b += 0.5 * green_component.b * (1.0 - localStrength.g);
			green_component.r -= 0.5 * green_component.r * (1.0 - localStrength.g);
			
			blue_component.b += 0.5 * blue_component.b * (1.0 - localStrength.b);
			blue_component.r -= 0.5 * blue_component.r * (1.0 - localStrength.b);
		}
		COLOR = vec4(red_component + green_component + blue_component, 1.0);
	}
}

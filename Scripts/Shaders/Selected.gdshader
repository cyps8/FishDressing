shader_type canvas_item;

uniform vec4 color_hue : source_color = vec4(1.0);

void fragment() {
	if (COLOR.a > 0.1 && COLOR.r < 0.1 && COLOR.g < 0.1 && COLOR.b < 0.1)
	{
		COLOR = vec4(color_hue.rgb, 1);
	}
	else
	{
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	}
}

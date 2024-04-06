shader_type canvas_item;

uniform vec4 color_hue : source_color = vec4(1.0);

void fragment() {
	if (COLOR.a > 0.1)
	{
		COLOR = vec4(color_hue.rgb, 0.5);
	}
}

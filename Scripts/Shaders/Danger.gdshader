shader_type canvas_item;

uniform vec4 color_hue : source_color = vec4(1.0);

void fragment() {
	if (COLOR.a > 0.1)
	{
		COLOR = vec4(color_hue.rgb, 0.9 * (cos((TIME * -10.0) + ((UV.y / TEXTURE_PIXEL_SIZE.y - UV.x / TEXTURE_PIXEL_SIZE.x) * .2)) * 1.5));
	}
	else
	{
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	}
}

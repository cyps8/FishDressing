shader_type canvas_item;

uniform vec4 color_hue : source_color = vec4(1.0);

void fragment() {
	if (COLOR.a > 0.001 && COLOR.r == COLOR.g && COLOR.r == COLOR.b)
	{
		COLOR = vec4(color_hue.rgb, (sin((UV.y / TEXTURE_PIXEL_SIZE.y + UV.x / TEXTURE_PIXEL_SIZE.x) / 7.0) + (cos((TIME * -10.0) + ((UV.y / TEXTURE_PIXEL_SIZE.y - UV.x / TEXTURE_PIXEL_SIZE.x) * .175)) * 5.0)) * 0.3);
	}
	else if (COLOR.a > 0.001)
	{
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
		//COLOR = vec4(color_hue.rgb, (sin((UV.y / TEXTURE_PIXEL_SIZE.y + UV.x / TEXTURE_PIXEL_SIZE.x) / 7.0) + (cos((TIME * -10.0) + ((UV.y / TEXTURE_PIXEL_SIZE.y - UV.x / TEXTURE_PIXEL_SIZE.x) * .175)) * 5.0)) * 0.0);
	}
	else
	{
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	}
}

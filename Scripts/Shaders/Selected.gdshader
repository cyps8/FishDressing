shader_type canvas_item;

uniform vec4 color_hue : source_color = vec4(1.0);

const vec2 OFFSETS[16] = {
	vec2(-0.71, -0.71), vec2(-1, 0), vec2(-0.71, 0.71), vec2(0, -1), vec2(0, 1), 
	vec2(0.71, -0.71), vec2(1, 0), vec2(0.71, 0.71),
	vec2(0.92, 0.38), vec2(0.38, 0.92), vec2(-0.92, 0.38), 
	vec2(-0.38, 0.92), vec2(0.92, -0.38), vec2(0.38, -0.92), vec2(-0.92, -0.38), vec2(-0.38, -0.92)
};

void fragment() {
	if (COLOR.a > 0.001 && COLOR.r == COLOR.g && COLOR.r == COLOR.b)
	{
		COLOR = vec4(color_hue.rgb, (sin((UV.y / TEXTURE_PIXEL_SIZE.y - UV.x / TEXTURE_PIXEL_SIZE.x) / 7.0) + (cos((TIME * -10.0) + ((UV.x / TEXTURE_PIXEL_SIZE.x + UV.y / TEXTURE_PIXEL_SIZE.y) * .125)) * 5.0)) * 0.3);
	}
	else if (COLOR.a > 0.001)
	{
		COLOR = vec4(color_hue.rgb, (sin((UV.y / TEXTURE_PIXEL_SIZE.y - UV.x / TEXTURE_PIXEL_SIZE.x) / 7.0) + (cos((TIME * -10.0) + ((UV.x / TEXTURE_PIXEL_SIZE.x + UV.y / TEXTURE_PIXEL_SIZE.y) * .125)) * 5.0)) * 0.0);
	}
	else
	{
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	}
}

shader_type canvas_item;

uniform vec3 color_hue;

vec2 random2( vec2 p ) {
	return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3))))*43758.5453);
}

void vertex() {
	//VERTEX += vec2(cos(TIME)*100.0, sin(TIME)*100.0);
}

void fragment() {
	vec2 st = UV;
	vec3 color = vec3(.0);
	st *= 10.0;
	vec2 i_st = floor(st);
	vec2 f_st = fract(st);
	float m_dist = 1.;
	for (int y= -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x), float(y));
			vec2 point = random2(i_st + neighbor);
			point = 0.5 + 0.5 * sin((TIME * 0.3) + 4.2831 * point);
			vec2 diff = neighbor + point - f_st;
			float dist = length(diff);
			m_dist = min(m_dist, dist);
		}
	}
	color += m_dist;
	color += 1.0-step(0.0, m_dist);
	COLOR = vec4(color_hue, color.b);
	//COLOR = texture(image, UV);
}
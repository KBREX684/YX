shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform float sanity_intensity : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float text_jitter_px : hint_range(0.0, 6.0, 0.1) = 2.0;
uniform vec4 tint_color : source_color = vec4(0.38, 0.05, 0.06, 0.18);

void vertex() {
	float jitter = sin(TIME * 38.0 + VERTEX.y * 0.035) * text_jitter_px * sanity_intensity;
	VERTEX.x += jitter;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	COLOR = mix(tex, tint_color, sanity_intensity * tint_color.a);
}

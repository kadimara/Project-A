shader_type canvas_item;

uniform sampler2D noice;
uniform float speed: hint_range(0.01, 0.05) = 0.04;
uniform float strength = 0.004;

void fragment() {
//	float noice_value = round(texture(noice, UV + TIME * speed).r);
	float noice_value = texture(noice, UV + vec2(0, TIME * speed)).r;
	COLOR = texture(TEXTURE, UV + vec2(0, noice_value) *  0.003);
//	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV + noice_value);
}

shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D noice;
uniform float speed: hint_range(0.01, 0.05) = 0.1;
uniform float strength = 0.004;

void fragment() {
	float noice_value = round(texture(noice, UV + TIME * speed).r);
//	float noice_value = round(texture(noice, UV).r);
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV + noice_value *  0.004);
}

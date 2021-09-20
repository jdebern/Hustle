shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_mask : hint_white;
//uniform vec4 replace_color : hint_color;
uniform sampler2D replace_color : hint_white;
uniform float threshold = 0.0;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	vec4 mask_sample = texture(screen_mask, SCREEN_UV);
	
	if( mask_sample.r >= threshold )
	{
//		COLOR = replace_color;
		COLOR = texture(replace_color, SCREEN_UV);
	}
	else
	{
		COLOR.a = 0.0;
	}
}
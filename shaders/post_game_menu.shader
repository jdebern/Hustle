shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_mask : hint_white;
uniform vec4 screen_mask_color : hint_color;
uniform vec4 color_mask : hint_color;
uniform vec4 color_replace : hint_color;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	vec4 mask_sample = texture(screen_mask, SCREEN_UV);
	
//	if (mask_sample == screen_mask_color)
//	{
//		COLOR.a = 0.0;
//	}
//	else
//	{
//		COLOR.a = 1.0;
//	}
	
	if (COLOR == color_mask)
	{
		COLOR = color_replace;
	}
}
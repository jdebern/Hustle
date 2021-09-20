shader_type canvas_item;
render_mode unshaded;

uniform sampler2D mask : hint_white;
uniform vec4 mask_color : hint_color;
uniform float Contrast = 1.0;
uniform float Brightness = 0.0;
uniform float offset = 0.0;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	vec4 mask_sample = texture(mask, SCREEN_UV);
	
	COLOR.rgb /= COLOR.a;
	COLOR.rgb = ((COLOR.rgb - 0.5) * max(Contrast, 0.0)) + 0.5;
	COLOR.rgb += Brightness;
	COLOR.rgb *= COLOR.a;
	
	float speed = 10.0;
	COLOR = texture(TEXTURE, UV);
	COLOR.r += sin(TIME * speed + offset) * 0.45;
	COLOR.g += sin(TIME * speed + offset) * 0.45;
	
	if (mask_sample == mask_color || COLOR.a == 0.0)
	{
		COLOR.a = 0.0;
	}
	else
	{
		COLOR.a = 1.0;
	}
}
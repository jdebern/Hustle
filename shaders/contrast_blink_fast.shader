shader_type canvas_item;
render_mode unshaded;

uniform float Contrast = 2.0;
uniform float Brightness = 1.0;
uniform bool Smooth = false;
uniform sampler2D mask : hint_white;
uniform vec4 mask_color : hint_color;

void fragment()
{
	COLOR = texture(TEXTURE, UV);
	vec4 mask_sample = texture(mask, SCREEN_UV);
	if( Smooth ) {
		COLOR.rgb /= COLOR.a;
		COLOR.rgb = ((COLOR.rgb - 0.5) * max(Contrast * (sin(TIME * 5.0) + 1.5), 0)) + 0.5;
		COLOR.rgb += Brightness;
		COLOR.rgb *= COLOR.a;
	}
	else {
		if (sin(TIME * 100.0) > 0.0) {
			COLOR.rgb /= COLOR.a;
			COLOR.rgb = ((COLOR.rgb - 0.5) * max(Contrast, 0.0)) + 0.5;
			COLOR.rgb += Brightness;
			COLOR.rgb *= COLOR.a;
		}
	}
	
	if (mask_sample == mask_color)
	{
		COLOR.a = 0.0;
	}
	else
	{
		COLOR.a = 1.0;
	}
}
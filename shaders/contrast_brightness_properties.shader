shader_type canvas_item;
render_mode unshaded;

uniform float Contrast = 1.0;
uniform float Brightness = 0.0;

void fragment()
{
	COLOR = texture(TEXTURE, UV);
	COLOR.rgb /= COLOR.a;
	COLOR.rgb = ((COLOR.rgb - 0.5) * max(Contrast, 0.0)) + 0.5;
	COLOR.rgb += Brightness;
	COLOR.rgb *= COLOR.a;
}
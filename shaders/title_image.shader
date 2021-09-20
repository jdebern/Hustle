shader_type canvas_item;
render_mode unshaded;

uniform sampler2D image : hint_white;
uniform int background_index : hint_range(0,2) = 0;

uniform vec4 MASK_0 : hint_color = vec4( 1.0, 1.0, 1.0, 1.0 );
uniform vec4 MASK_1 : hint_color = vec4( 0.7490196078431373, 0.7490196078431373, 0.7490196078431373, 1.0 );
uniform vec4 MASK_2 : hint_color = vec4( 0.4980392156862745, 0.4980392156862745, 0.4980392156862745, 1.0 );
uniform vec4 MASK_3 : hint_color = vec4( 0.2470588235294118, 0.2470588235294118, 0.2470588235294118, 1.0 );
uniform vec4 MASK_4 : hint_color = vec4( 0.00, 0.00, 0.00, 1.0 );

uniform vec4 BG_0_MASK_0 : hint_color = vec4( 0.78, 0.97, 0.76, 1.0 );
uniform vec4 BG_0_MASK_1 : hint_color = vec4( 0.19, 0.39, 0.34, 1.0 );
uniform vec4 BG_0_MASK_2 : hint_color = vec4( 0.11, 0.27, 0.24, 1.0 );
uniform vec4 BG_0_MASK_3 : hint_color = vec4( 0.07, 0.19, 0.18, 1.0 );
uniform vec4 BG_0_MASK_4 : hint_color = vec4( 0.10, 0.16, 0.12, 1.0 );

uniform vec4 BG_1_MASK_0 : hint_color = vec4( 0.79, 0.51, 0.22, 1.0 );
uniform vec4 BG_1_MASK_1 : hint_color = vec4( 0.69, 0.48, 0.19, 1.0 );
uniform vec4 BG_1_MASK_2 : hint_color = vec4( 0.60, 0.31, 0.20, 1.0 );
uniform vec4 BG_1_MASK_3 : hint_color = vec4( 0.33, 0.26, 0.21, 1.0 );
uniform vec4 BG_1_MASK_4 : hint_color = vec4( 0.18, 0.18, 0.19, 1.0 );

uniform vec4 BG_2_MASK_0 : hint_color = vec4( 0.67, 0.42, 0.54, 1.0 );
uniform vec4 BG_2_MASK_1 : hint_color = vec4( 0.53, 0.36, 0.51, 1.0 );
uniform vec4 BG_2_MASK_2 : hint_color = vec4( 0.32, 0.18, 0.29, 1.0 );
uniform vec4 BG_2_MASK_3 : hint_color = vec4( 0.26, 0.14, 0.11, 1.0 );
uniform vec4 BG_2_MASK_4 : hint_color = vec4( 0.19, 0.13, 0.22, 1.0 );

bool matches( vec4 a, vec4 b ) {
	vec4 delta = vec4( b.r - a.r, b.b - a.b, b.g - a.g, 0.0 );
	return length( delta ) < 0.1;
//	return ( delta.r < 0.01 && delta.b < 0.01 && delta.g < 0.01 );
}

vec4 get_color_from_masks( vec4 mask_sample, vec4 mask_0, vec4 mask_1, vec4 mask_2, vec4 mask_3, vec4 mask_4 ) {
	if ( matches(mask_sample, MASK_0) )
	{
		return mask_0;
	}
	else if ( matches(mask_sample, MASK_1) )
	{
		return mask_1;
	}
	else if ( matches(mask_sample, MASK_2) )
	{
		return mask_2;
	}
	else if ( matches(mask_sample, MASK_3) )
	{
		return mask_3;
	}
	else if( matches(mask_sample, MASK_4) )
	{
		return mask_4;
	}
	else
	{
		return vec4( 0.0, 0.0, 0.0, 0.0 );
	}
}

void fragment() {	
	vec4 mask_sample = texture(image, UV);
	
	if (background_index == 0)
	{
		COLOR = get_color_from_masks( mask_sample, BG_0_MASK_0, BG_0_MASK_1, BG_0_MASK_2, BG_0_MASK_3, BG_0_MASK_4 );
	}
	else if (background_index == 1)
	{
		COLOR = get_color_from_masks( mask_sample, BG_1_MASK_0, BG_1_MASK_1, BG_1_MASK_2, BG_1_MASK_3, BG_1_MASK_4 );
	}
	else
	{
		COLOR = get_color_from_masks( mask_sample, BG_2_MASK_0, BG_2_MASK_1, BG_2_MASK_2, BG_2_MASK_3, BG_2_MASK_4 );
	}
	
	/*if ( mask_sample.a == 0.0 )
	{
		COLOR.a = 0.0;
	}*/
}
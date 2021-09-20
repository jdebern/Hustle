#	PARALLAX TEXTURE
#

extends Polygon2D
class_name ParallaxTexture

export( float ) var Timescale : float = 1.0

var _time : float = 0.0

func _process( delta : float ) -> void:
	_time += delta
	set_texture_offset( Vector2( _time * Timescale, 0 ) )
	
	pass # _ready()
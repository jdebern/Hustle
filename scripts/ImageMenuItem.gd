# IMAGE MENU ITEM
#
extends Sprite

# Offsets used to widen sprite at each interval
export(Array) var TextureOffsets

# How long it takes to show the full sprite
export(float) var FilloutTime : float

var _fill_timer : Timer = Timer.new()

func _ready():
	
	assert( FilloutTime > 0.0 )
	assert( TextureOffsets.size() > 0 )
	
	add_child( _fill_timer )
	var waitTime : float = FilloutTime / TextureOffsets.size()
	_fill_timer.set_wait_time( waitTime )
	_fill_timer.start()
	assert( _fill_timer.connect( "timeout", self, "_on_fill_timer_tick" ) == OK )
	
	set_region_rect(Rect2(0,0,0,get_texture().get_height()))
	pass # _ready()

func _on_fill_timer_tick():
	
	var rect : Rect2 = get_region_rect()
	var total : int = 0
	for i in range( TextureOffsets.size() ):
		total += TextureOffsets[i]
		if rect.size.x < total:
			rect.size.x += TextureOffsets[i]
			break
		pass
		
	set_region_rect(rect)
	if rect.size.x >= get_texture().get_width():
		_fill_timer.stop()
		
	pass # _on_fill_timer_tick()
	
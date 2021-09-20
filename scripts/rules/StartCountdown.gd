# START COUNTDOWN
#	Counts down from 3 to 1
#	Does some fancy scaling and transition out

extends Sprite

const MathHelper = preload( "res://scripts/helpers/MathHelper.gd" )
const title_image_material = preload( "res://materials/title_image_material.tres" )

export(Rect2) var Region_3 = null
export(Rect2) var Region_2 = null
export(Rect2) var Region_1 = null
export(Rect2) var Region_Go = null

var _countdown_timer = Timer.new()
var _s = 0
var _count = 3
var _start_pos = null
var _transition_time = 0

func _ready():
	add_child(_countdown_timer)
	_countdown_timer.set_wait_time(1.0)
	_countdown_timer.connect("timeout", self, "_on_tick")
	_countdown_timer.start()
	_countdown_timer.set_name("countdown_timer")
	set_region_rect(Region_3)
	set_material( title_image_material )


func _on_tick():
	_count -= 1
	_s = 0
	if _count == 2:
		set_region_rect(Region_2)
	elif _count == 1:
		set_region_rect(Region_1)
	else:
		_countdown_timer.stop()
		set_region_rect(Region_Go)
		_start_pos = get_position()
		set_scale(Vector2(1,1))


func _process(delta):

	if _countdown_timer.is_stopped():
		_transition_time += delta
		var newY = MathHelper.in_back(_transition_time, _start_pos.y, -200, 1.0, 1)
		set_position(Vector2(_start_pos.x, newY))
		# fly off screen
		if get_position().y < -300:
			get_parent().remove_child(self)
			queue_free()

	else:
		var timeleft = _countdown_timer.get_time_left()
		_s += delta * 8
		var scale = 1 + sin(_s) * (timeleft - floor(timeleft))
		set_scale(Vector2(scale,scale))

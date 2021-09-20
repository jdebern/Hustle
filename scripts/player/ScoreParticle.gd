# Score PARTICLE
#	- Zooms to a target position

extends Sprite

const CAMERA_WIDTH = 320
const CAMERA_HEIGHT = 240
const X_OFFSET = 40
const Y_OFFSET = 20

const MathHelper = preload("res://scripts/helpers/MathHelper.gd")

export(int) var color = 0
var _timer = Timer.new()
var _start_pos = null
var _target_pos = null

signal Complete

func _ready():
	add_child(_timer)
	_timer.set_wait_time(0.65)
	_timer.set_one_shot(true)
	_timer.start()
	_timer.connect("timeout", self, "_on_tick")

	
func init():
	set_region_rect(Rect2(color * 8, 0, 8, 8))
	_start_pos = get_global_position()
	_target_pos = get_node("../multiplier").avatar_location
#	_target_pos = Vector2(CAMERA_WIDTH, CAMERA_HEIGHT) * 0.5
#	if get_global_position().x > _target_pos.x:
#		_target_pos.x -= X_OFFSET
#	else:
#		_target_pos.x += X_OFFSET
#	_target_pos.y += rand_range(-Y_OFFSET, Y_OFFSET)


func _process(delta):
	# in_back the X
	var newX = MathHelper.in_back(
			_timer.get_wait_time() - _timer.get_time_left(),
			_start_pos.x,
			_target_pos.x - _start_pos.x,
			_timer.get_wait_time(),
			1)
	# in_out_cubic the Y
	var newY = MathHelper.in_out_cubic(
		_timer.get_wait_time() - _timer.get_time_left(),
		_start_pos.y,
		_target_pos.y - _start_pos.y,
		_timer.get_wait_time())

	set_global_position(Vector2(newX, newY))


func _on_tick():
	emit_signal("Complete", self)
	queue_free()

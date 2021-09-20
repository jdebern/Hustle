# MULTIPLIER
#  - little multiplier on the player showing how many incoming rows
extends Sprite

var MathHelper = preload("res://scripts/helpers/MathHelper.gd")
var PlayerHelper = preload("res://scripts/helpers/PlayerHelper.gd")

var _wait_timer = Timer.new()
var _transition_timer = Timer.new()
var _start_pos = null

var avatar_location = null

var count = 0
var color_offset = 0

const OFFSET = 90

signal MultiplierCollect


func _ready():
	add_child(_wait_timer)
	add_child(_transition_timer)
	
	_wait_timer.set_wait_time(1.0)
	_wait_timer.set_one_shot(true)
	_wait_timer.connect("timeout", self, "_on_wait_tick")
	_wait_timer.set_name("wait_timer")
	_transition_timer.set_wait_time(0.85)
	_transition_timer.set_one_shot(true)
	_transition_timer.connect("timeout", self, "_on_transition_tick")
	_transition_timer.set_name("transition_timer")
	
	_start_pos = get_position()
	move_local_y(60)
	color_offset = get_region_rect().position.y

	avatar_location = get_node("../avatar").get_global_position()
	

func set_count(multi):
	count = clamp(multi, 1, 8)


func focus_and_play():
	set_region_rect(Rect2(16*(count-1), color_offset, 16, 16))
	_wait_timer.stop()
	_transition_timer.stop()
	_wait_timer.set_wait_time(PlayerHelper.SCORE_TIMES[min(count, 3)])
	set_position(_start_pos)
	_wait_timer.start()
	

func _process(delta):
	if !_transition_timer.is_stopped():
		var newY = MathHelper.in_back(
				_transition_timer.get_wait_time()-_transition_timer.get_time_left(),
				_start_pos.y,
				OFFSET,
				_transition_timer.get_wait_time(), 1)
		set_position(Vector2(_start_pos.x, newY))
	if !_wait_timer.is_stopped():
		var newY = min(get_position().y + delta * 3, _start_pos.y)
		set_position(_start_pos + Vector2(0, sin(_wait_timer.get_time_left() *  55)))


func _on_transition_tick():
	emit_signal("MultiplierCollect", get_parent(), count)
	count = 0

func _on_wait_tick():
	_transition_timer.start()


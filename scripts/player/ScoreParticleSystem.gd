# SCORE PARTICLE SYSTEM
# 	- Custom circle behavior and complete signal

extends Node2D

var _timer = Timer.new()
var _sprites = []
var _directions = [
	Vector2(-1,-1),
	Vector2(1,-1),
	Vector2(1,1),
	Vector2(-1,1)
]

export(int) var color = 1
export(float) var offset = 20.0
export(float) var lifetime = 1.0

signal Complete


func _ready():
	_sprites.append($topleft)
	_sprites.append($topright)
	_sprites.append($bottomleft)
	_sprites.append($bottomright)

	for i in range(4):
		_sprites[i].set_position(_directions[i] * offset)
		_sprites[i].set_region_rect(Rect2(color * 6, 0, 6, 6))
	
	add_child(_timer)
	_timer.set_wait_time(lifetime)
	_timer.set_one_shot(true)
	_timer.start()
	_timer.connect("timeout", self, "_on_tick")


func _process(delta):
	for i in range(4):
		var radians = MathHelper.out_quart(
				_timer.get_wait_time()-_timer.get_time_left(),
				0,
				PI,
				_timer.get_wait_time()+0.8)

		var new_pos = MathHelper.out_quart(
				_timer.get_wait_time()-_timer.get_time_left(),
				_directions[i] * offset,
				_directions[i] * -offset * 1.0,
				_timer.get_wait_time()+0.8)

		new_pos = MathHelper.rotate_around(new_pos, Vector2(), radians)
		_sprites[i].set_position(new_pos)


func _on_tick():
	emit_signal("Complete")
	#get_parent().remove_child(self)
	queue_free()

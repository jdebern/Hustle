extends Node

var direction = Vector2(0,-1)
var acceleration = 1.0
var delay = 0.0
var speed = 400.0
var acceleration_limit = 1000.0

func _process(delta):
	delay -= delta
	if delay <= 0.0:
		acceleration = min(acceleration + delta * speed, acceleration_limit)
		var block = get_parent()
		block.set_global_position(block.get_global_position() + (Vector2(direction.x, direction.y) * acceleration * delta))
		
		if block.get_global_position().y > 240.0:
			var block_grid = block.get_parent()
			block_grid.free_block(block)
	pass


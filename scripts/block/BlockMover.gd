# BLOCK MOVER
#	- Responsible for translations of the block
#		> Falling, Swapping

extends Node

# Public vars
var Block = null
var BlockGrid = null
var TargetPosition = null
var Landed = false
var Freeze = false

export(float) var FallSpeed = 100

# Private vars
var _swapTimer = Timer.new()
var _rows_fallen = 0


func _ready():
	Block = get_parent()
	BlockGrid = Block.get_parent()

	_swapTimer.set_wait_time(0.15)
	_swapTimer.set_one_shot(true)
	add_child(_swapTimer)
	_swapTimer.connect("timeout", self, "_on_swapTimer_Tick")
	_swapTimer.set_name("swap_timer")
	pass

#
func _on_swapTimer_Tick():
	Block.set_position(TargetPosition)
#warning-ignore:integer_division
	var x_index : int = int(TargetPosition.x) / int(Block.SIZE)
#warning-ignore:integer_division
	var y_index : int = int(TargetPosition.y + Block.SIZE - 1) / int(Block.SIZE)
	TargetPosition = null
	Freeze = false
	BlockGrid.set_pending_evaluate()
	pass
	

# sets target position for block to interp to
func set_target(pos):
	TargetPosition = pos
	if pos != null:
		_swapTimer.start()
	else:
		_swapTimer.stop()
	pass
	

# handles cases for block movement when falling
func fall(delta):
	if Freeze:
		return
		
	var dy = clamp(FallSpeed * delta, 0, Block.SIZE-1)
	var x_index = Block.grid_indices[0]
	var y_index = Block.grid_indices[1]
	var next_y_index = y_index + 1
		
	# Check if we can move into the next index
	var next_is_empty = true
	if next_y_index >= BlockGrid.GridHeight:
		next_is_empty = false
	else:
		next_is_empty = !BlockGrid.get_block(x_index, next_y_index)
		
	if next_is_empty:
		# We can move into the next index
		_rows_fallen += 1
		BlockGrid.set_block(x_index, y_index, null)
		BlockGrid.set_block(x_index, next_y_index, Block)
		Block.set_position(Block.get_position() + Vector2(0, dy))
		Landed = false
	else:
		# Next block is not empty
		# Figure out how far we can move this frame and land if we need
		var new_block_pos : Vector2 = Block.get_position() + Vector2(0, dy)
#warning-ignore:narrowing_conversion
		var new_pos_index : int = floor( ( new_block_pos.y + Block.SIZE - 1 ) / Block.SIZE )
		if new_pos_index == next_y_index:
			Block.set_position(Vector2(Block.grid_indices[0], Block.grid_indices[1]) * Block.SIZE)
			Block.land(_rows_fallen > 0)
		else:
			Block.set_position(new_block_pos)
			Landed = false
	pass
		

# handles moving block to target
func swap(delta):
	var newPos = Block.get_position().linear_interpolate(
			TargetPosition,
			1 - (_swapTimer.get_time_left() / _swapTimer.get_wait_time()))
	Block.set_position(newPos)
	pass

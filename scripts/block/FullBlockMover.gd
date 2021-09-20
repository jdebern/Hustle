# FULL BLOCK MOVER
#

extends "res://scripts/block/BlockMover.gd"


func fall(delta):
	var dy = clamp(FallSpeed * delta, 0, Block.SIZE-1)
	var x_index = Block.grid_indices[0]
	var y_index = Block.grid_indices[1]
	var next_y_index = y_index + 1
		
	# Check if we can move into the next index
	var next_is_empty = true
	
	for column in range(BlockGrid.GridWidth):
		if next_y_index >= BlockGrid.GridHeight:
			next_is_empty = false
		else:
			next_is_empty = !BlockGrid.get_block(column, next_y_index)
		
		if !next_is_empty:
			break
		
	if next_is_empty:
		# We can move into the next index
		_rows_fallen += 1
		for i in range(BlockGrid.GridWidth):
			BlockGrid.set_block(i, y_index, null)
			BlockGrid.set_block(BlockGrid.GridWidth-i-1, next_y_index, Block)
					
		Block.set_position(Block.get_position() + Vector2(0, dy))
		Landed = false
	else:
		# Next block is not empty
		# Figure out how far we can move this frame and land if we need
		var new_block_pos = Block.get_position() + Vector2(0, dy)
#warning-ignore:integer_division
		var new_pos_index = int(new_block_pos.y + Block.SIZE - 1) / int(Block.SIZE)
		if new_pos_index == next_y_index:
			Block.set_position(Vector2(Block.grid_indices[0], Block.grid_indices[1]) * Block.SIZE)
			Block.land(_rows_fallen > 0)
		else:
			Block.set_position(new_block_pos)
			Landed = false


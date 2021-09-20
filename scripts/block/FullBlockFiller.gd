# FULL BLOCK FILLER
#	Fills a full block with new blocks as its scoring
#
# !-REQUIRES REFACTORING-!
# When a full block is scored:
#	1.	Create Individual blocks with a new component ( BLOCK_FILLER )
#	1.a	The full block is converted into a fx object that clears automatically
#	2.	The BLOCK_FILLER component waits for 0.66 seconds and then sets a CLEAR flag
#	3.	BLOCK_GRID looks for clear flag and allows the new blocks to unfreeze
# 

extends Node

const FastBlink = preload("res://materials/fast_blink_material.tres")

var _block = null
var _new_blocks = []
var _pop_timer = Timer.new()
var _loop = 0

func _ready():
	add_child(_pop_timer)
	_pop_timer.set_wait_time(0.33)
	_pop_timer.set_timer_process_mode(Timer.TIMER_PROCESS_PHYSICS)
	_pop_timer.connect("timeout", self, "_on_pop")
	
	pass # _ready
	
func _on_pop():
	var block_grid = get_parent()
	if !block_grid || !_block:
		breakpoint
		_pop_timer.stop()
		_pop_timer.disconnect("timeout", self, "_on_pop")
		return
		
		
	if _loop < 1:
		# FIRST LOOP: creates the new blocks but suspends them until following loop
		_new_blocks.resize(block_grid.GridWidth)
		for x in range(block_grid.GridWidth):
			var new_block = block_grid.create_block(PlayerHelper.get_random_blocktype())
			new_block.mover.Landed = true
			new_block.mover.Freeze = true
			new_block.sprite.set_material(FastBlink)
			new_block.set_position(Vector2(x, _block.grid_indices[1]) * _block.SIZE)
			new_block.build_name()
			_new_blocks[x] = new_block
	else:
		#SECOND LOOP: drops the newly created row of blocks
		for x in range(block_grid.GridWidth):
			var new_block = _new_blocks[x]
			new_block.mover.Freeze = false
			new_block.mover.Landed = false
			new_block.sprite.set_material(new_block.default_material)			
			block_grid.set_block(x, _block.grid_indices[1], new_block)
		
		_pop_timer.stop()
		_pop_timer.disconnect("timeout", self, "_on_pop")
		
		block_grid.free_block(_block)
		block_grid.remove_child(self)
		queue_free()
		
	_loop += 1
	pass # _physics_process
	
func set_block(block):
	_block = block
	_pop_timer.start()
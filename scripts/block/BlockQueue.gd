# BLOCK QUEUE
#	- Holds array of 5 (GRIDWIDTH) blocks
#	- Dumps the blocks on a player every N seconds
#	- Also holds (GRIDWITH) of indicator objects to flash before dropping
extends Node

# Block script
const Block = preload("res://scripts/block/Block.gd")


# Public vars
enum { SINGLE, FULL }

class QueueData:
	var data_type = SINGLE
	var block_type = PlayerHelper.BLOCKTYPES.SPECIAL
	var count = 0
	var timer = Timer.new()


# Private vars
var _queue = []


# TODO: needs to handle logic for a full-width block (indicators)
func add_data(block_type, data_type, count, wait_time):
	var data = QueueData.new()
	data.data_type = data_type
	data.block_type = block_type
	data.count = count
	data.timer.set_wait_time(wait_time + _queue.size() * 0.25)
	data.timer.set_one_shot(true)
	data.timer.connect("timeout", self, "_on_data_ready", [data])
	add_child(data.timer)
	data.timer.start()
	_queue.push_back(data)


func _on_data_ready(data):
	if _queue.size() == 0:
		return
	
	var player = get_parent().get_parent()
	if data.data_type == SINGLE:
		var lastCol = 0
		for i in range(data.count):
			var newBlock = player.block_grid.create_block((data.block_type + i) % PlayerHelper.ColorCount)
			newBlock.mover.Landed = false
			var col = randi() % player.block_grid.GridWidth
			if col == lastCol:
				col = (col + 1) % player.block_grid.GridWidth
			newBlock.set_position(Vector2(col * Block.SIZE, 0))
			player.block_grid.set_block(col, 0, newBlock)
			lastCol = col
	else:
		var newBlock = player.block_grid.create_full_block()
		newBlock.mover.Landed = false
		newBlock.set_position(Vector2(0, 0))
		for i in range(player.block_grid.GridWidth):
			player.block_grid.set_block(player.block_grid.GridWidth-i-1, 0, newBlock)
			
				
	remove_child(data.timer)
	data.timer.queue_free()
	data.timer.disconnect("timeout", self, "_on_data_ready")
	
	var index = _queue.find(data)
	_queue.remove(index)
	

func clear_queue():
	for data in _queue:
		remove_child(data.timer)
		data.timer.queue_free()
		data.timer.disconnect("timeout", self, "_on_data_ready")

	_queue.clear()
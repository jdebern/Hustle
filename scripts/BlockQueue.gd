# BLOCK QUEUE
#	- Holds array of 5 (GRIDWIDTH) blocks
#	- Dumps the blocks on a player every N seconds
#	- Also holds (GRIDWITH) of indicator objects to flash before dropping
extends Node2D

# Block script
var Block = preload("res://scripts/Block.gd")
# Block scene
var BlockScene = preload("res://scenes/block.tscn")

# Private Vars
var _player = null
var _queue = []
var _alerts = []
var _gridWidth = -1

# Public Vars
export(float) var DropInterval = 1.0


func _ready():
	# grab the player
	self._player = get_parent()
	self._gridWidth = self._player.GridWidth
	# create the queue
	self._queue.resize(5)
	for i in range(5):
		var row = []
		row.resize(self._gridWidth)
		for x in range(self._gridWidth):
			row[x] = PlayerHelper.BLOCKTYPES.EMPTY
		self._queue[i] = row
	# create alert icons
	self._alerts.resize(self._gridWidth)
	for i in range(self._gridWidth):
		var newBlock = BlockScene.instance()
		newBlock.centered = false
		newBlock.set_blocktype(PlayerHelper.BLOCKTYPES.RED, "_alert")
		newBlock.set_position(Vector2(i*newBlock.SIZE, 0))
		self._alerts[i] = newBlock
		self.add_child(self._alerts[i])


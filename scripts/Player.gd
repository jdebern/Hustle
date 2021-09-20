# PLAYER
extends Node

# Player helpers
var PlayerHelper = preload("res://scripts/helpers/PlayerHelper.gd")
# Block script
var Block = preload("res://scripts/Block.gd")

#Public Vars
export(int) var GridWidth = 6
export(int) var GridHeight = 12

#Private Vars
var _blockMatrix = [] # grid array for block lookup
var _blockStorage = Node2D.new() # stores all the block scene objects
var _blockTimer = Timer.new()
var _scoreTimer = Timer.new()

var _typeToDrop = [
	PlayerHelper.BLOCKTYPES.YELLOW,
	PlayerHelper.BLOCKTYPES.YELLOW,
	PlayerHelper.BLOCKTYPES.YELLOW,
	PlayerHelper.BLOCKTYPES.RED,
	PlayerHelper.BLOCKTYPES.ORANGE,
	PlayerHelper.BLOCKTYPES.BLUE,
	PlayerHelper.BLOCKTYPES.BLUE
]
var _xstep = 0
var _blockCount = 0


func _ready():
	self.add_child(self._blockStorage)
	self.add_child(self._blockTimer)
	self.add_child(self._scoreTimer)
	# score timer
	self._scoreTimer.set_wait_time(1.15)
	self._scoreTimer.connect("timeout", self, "_on_scoreTimer_Tick")
	self._scoreTimer.set_one_shot(true)
	# block timer
	self._blockTimer.set_wait_time(0.35)
	self._blockTimer.connect("timeout", self, "_on_blockTimer_Tick")
	self._blockTimer.start()
	# create block grid
	self._blockMatrix.resize(self.GridWidth)
	var BlockScene = load("res://scenes/block.tscn")
	for x in range(self.GridWidth):
		self._blockMatrix[x] = []
		self._blockMatrix[x].resize(self.GridHeight)
		var count = 0
		for y in range(self.GridHeight):
			var newBlock = PlayerHelper.CreateBlock(
				BlockScene,
				PlayerHelper.BLOCKTYPES.EMPTY,
				"block_"+String(count))

			self._blockMatrix[x][y] = newBlock
			newBlock.alignToGrid(x, y)
			self._blockStorage.add_child(newBlock)
			count += 1


func _on_scoreTimer_Tick():
	self._blockTimer.set_paused(false)
	for x in range(self.GridWidth):
		for y in range(self.GridHeight):
			var block = self.getBlock(x, y)
			if block.Scored:
				block.Scored = false
				block.set_blocktype(PlayerHelper.BLOCKTYPES.EMPTY)


func _on_blockTimer_Tick():
	var newBlockType = self._typeToDrop[self._blockCount % self.GridWidth]
	self.addBlock(self._xstep, newBlockType)
	self._xstep += 1
	if self._xstep >= self.GridWidth:
		self._xstep = 0
	self._blockCount += 1


func _process(delta):
	# move blocks and evaluate combos
	if self._scoreTimer.is_stopped():
		self.moveBlocks(delta)
		
		
func getBlock(x, y):
	return self._blockMatrix[x][y]


func addBlock(column, type):
	if column >= self.GridWidth:
		printerr("Tried to add block out of bounds ", column, " >= ", self.GridWidth)
	
	var block = self._blockMatrix[column][0]
	if block.Type == PlayerHelper.BLOCKTYPES.EMPTY:
		block.set_blocktype(type)
		block.alignToGrid(column, 0)
		block.IsFalling = true
	
	
func moveBlocks(delta):
	var blocks = self._blockStorage.get_children()
	var anyBlockLanded = false
	for block in blocks:
		if block.IsFalling:
			var moveOffset = Vector2(0, block.FallSpeed * delta)
			var localPos = block.get_position()
			var currentCol = localPos.x / block.SIZE
			var currentRow = floor((localPos.y + block.SIZE - 1) / block.SIZE)
			var nextRow = floor((localPos.y + moveOffset.y + block.SIZE) / block.SIZE)
			if nextRow >= self.GridHeight:
				block.alignToGrid(currentCol, currentRow)
				block.IsFalling = false
				anyBlockLanded = true
				continue
			
			# REDO THE LOGIC DOWN HERE ( CASES )
			if nextRow != currentRow: # we're moving into a new block
				var nextBlock = self._blockMatrix[currentCol][nextRow]
				if nextBlock.Type == PlayerHelper.BLOCKTYPES.EMPTY: # next block is empty, SWAP
					self._blockMatrix[currentCol][currentRow] = nextBlock
					self._blockMatrix[currentCol][nextRow] = block
					nextBlock.alignToGrid(currentCol, currentRow)
					block.translate(moveOffset)
				elif nextBlock == block: # we are moving into ourselves
					block.translate(moveOffset)
				else: # next block is occupied, set to current
					block.alignToGrid(currentCol, currentRow)
					block.IsFalling = false
					anyBlockLanded = true

			else:
				block.translate(moveOffset)
	
	if anyBlockLanded:
		evaluateCombos()


func evaluateCombos():
	var anyScored = PlayerHelper.EvaluateColumns(self, Block)
	anyScored = PlayerHelper.EvaluateRows(self, Block) || anyScored

	if anyScored:
		self._scoreTimer.start()
		self._blockTimer.set_paused(true)


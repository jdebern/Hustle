# CURSOR CONTROL
#
extends Node2D

# Block script (to steal the SIZE)
const Block = preload("res://scripts/block/Block.gd")

# Public vars

# Private vars
var _grid_dimensions = Vector2(0, 0)
var _grid_vectors = [ Vector2(2, 12), Vector2(3, 12) ]
var _cursors = [ null, null ]
var _frozen = true
var player_input = null
var block_grid = null

export(bool) var UseMouse = false

signal CursorSwapAction

func _ready():
	block_grid = get_parent()
	_grid_dimensions = Vector2(block_grid.GridWidth, block_grid.GridHeight)
	_cursors[0] = $cursor_a
	_cursors[1] = $cursor_b
	reset()
	pass


func _physics_process(delta):
	if player_input:
		if !_frozen && Input.is_action_just_pressed(player_input.swap):
			_swap_blocks()
		else:
			var inputStep = Vector2(0, 0)
			if Input.is_action_just_pressed(player_input.right):
				inputStep.x = 1
			elif Input.is_action_just_pressed(player_input.left):
				inputStep.x = -1
			elif Input.is_action_just_pressed(player_input.up):
				inputStep.y = -1
			elif Input.is_action_just_pressed(player_input.down):
				inputStep.y = 1
		
			if inputStep != Vector2():
				translate_cursors(inputStep)
	pass


func _input(ev):
	if _frozen:
		return
		
	if ev is InputEventMouseMotion:
		var localpos = to_local(ev.position)
		var xIndex = int(localpos.x / Block.SIZE)
		var yIndex = int(localpos.y / Block.SIZE)

		if Vector2(xIndex, yIndex) == _grid_vectors[0]:
			return
			
		var width = block_grid.GridWidth
		var height = block_grid.GridHeight

		if xIndex < 0 || yIndex < block_grid.GridHeight - block_grid.DisplayHeight \
			|| xIndex > width - 1 || yIndex > height - 1:
			return

		if xIndex == width - 1:
			xIndex -= 1
			
		_grid_vectors[0] = Vector2(xIndex, yIndex)
		_grid_vectors[1] = Vector2(xIndex + 1, yIndex)
		_align_to_grid()
		ping()
	pass # _input()


func _swap_blocks():
	# initialize the swap
	var blocks = [ block_grid.get_block(_grid_vectors[0].x, _grid_vectors[0].y) \
			, block_grid.get_block(_grid_vectors[1].x, _grid_vectors[1].y)  ]
	if !blocks[0] && !blocks[1]:
		return
		
	for i in range(2):
		if blocks[i] && (blocks[i].scored || !blocks[i].mover.Landed || blocks[i].Type == PlayerHelper.BLOCKTYPES.FULL):
			return
	
	for i in range(2):
		block_grid.set_block(_grid_vectors[i].x, _grid_vectors[i].y, blocks[1-i])
		if blocks[i]:
			blocks[i].mover.Landed = false
			blocks[i].mover.Freeze = true
			blocks[i].mover.set_target(_grid_vectors[1-i] * Block.SIZE)

	ping()
	pass # _swap_blocks()


func _align_to_grid():
	for i in range(2):
		_cursors[i].set_position(\
			Vector2((_grid_vectors[i].x * Block.SIZE) + (Block.SIZE * 0.5),\
			(_grid_vectors[i].y * Block.SIZE) + (Block.SIZE * 0.5)))
	pass # _align_to_grid()


func reset():
	_grid_vectors[0] = Vector2(2, 12)
	_grid_vectors[1] = Vector2(3, 12)
	_align_to_grid()
	set_visible(true)


func translate_cursors(translation):
	var newVectors = \
		[ _grid_vectors[0] + translation , _grid_vectors[1] + translation ]
	for i in range(2):
		if newVectors[i].x >= _grid_dimensions.x \
			|| newVectors[i].y >= _grid_dimensions.y \
			|| newVectors[i].y < 0 || newVectors[i].x < 0:
			return

	_grid_vectors = newVectors
	_align_to_grid()
	if translation != Vector2():
		ping()
	pass # translate_cursors()


func set_frozen(freeze):
	_frozen = freeze
	pass # set_frozen()
	

func set_input(new_input):
	player_input = new_input
	pass


func ping():
	for i in range(2):
		_cursors[i].set_frame(0)
		_cursors[i].play()
	pass # ping()


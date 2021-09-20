# BLOCK GRID
#	- The game grid that holds a representation of block types
#	- Also contains pool of block sprites
#    y 0~n
#   x+------>
#  0 |
#  ~ |
#  n |
#    V

extends Node2D

const Block				= preload( "res://scripts/block/Block.gd" )
const MathHelper		= preload( "res://scripts/helpers/MathHelper.gd" )
const BlockScene		= preload( "res://scenes/block/block.tscn" )
const FullBlockScene	= preload( "res://scenes/block/full_block.tscn" )
const LoserMove			= preload( "res://scenes/block/loser_mover.tscn" )
const DarkMaterial		= preload( "res://materials/masked_dark_material.tres" )
const BlinkMaterial		= preload( "res://materials/hue_scroll_material.tres" )
const FastBlinkMaterial = preload( "res://materials/fast_blink_material.tres" )

onready var player : Sprite = find_parent( "player_?")

# Private vars
var _start_position				:= Vector2( 0, 0 )
var _scored_this_frame : int	= 0
var _pending_evaluate : bool	= false
var _pending_frames : int		= 0
var _blockMatrix				:= Array() # grid array for block lookup
var _incoming_blocks			:= Array()
var _ascend_timer : Timer		= Timer.new()

# Public vars
const GridWidth : int		= 6  # These can be export for instance editing, would just
const GridHeight : int		= 20 # need to convert block_grid and children to another scene
const DisplayHeight : int	= 10 # The number of actual rows on screen
const vOFFSCREEN			:= Vector2( 0,9999 )
const EVALUATE_BUFFER : int	= 5


func _ready() -> void:
	_incoming_blocks.resize( GridWidth )
	_blockMatrix.resize( GridWidth )
	for x in range( GridWidth ):
		_blockMatrix[x] = []
		_blockMatrix[x].resize( GridHeight )
		
		for y in range( GridHeight ):
			_blockMatrix[x][y] = null

	_start_position = $floor.get_position() - Vector2( 0, Block.SIZE ) * GridHeight
	set_position( _start_position )
	
	add_child(_ascend_timer )
	_ascend_timer.set_one_shot( true )
	_ascend_timer.set_name( "ascend_timer" )
	
	reset()
	
	pass # ready()
	

func _on_delayed_fall_tick( block : Node2D ) -> void:
	if block:
		block.mover.Freeze = false
		block.mover.Landed = false
		block.sprite.set_material( block.default_material )
		
	pass # _delay_block_fall
		

func _physics_process( delta : float ) -> void:
	if player.game_over:
		return
		
	var is_swapping = false
	var is_scoring = false
	var highest_index = 0
	
	# create any new blocks
	for x in range( GridWidth ):
		for y in range( GridHeight ):
			
			var block = get_block( x, y )
			if block && block.state == PlayerHelper.BLOCKSTATE.FULL_SCORED:
				# -- Create a new block row now that the full block is being cleared
				for col in range ( GridWidth ):

					var new_block = create_block( PlayerHelper.get_random_blocktype() )
					new_block.mover.Landed = true
					new_block.mover.Freeze = true
					new_block.sprite.set_material( FastBlinkMaterial )
					new_block.scored_this_frame = false
					new_block.set_position( Vector2( col, y ) * Block.SIZE )
					set_block( col, y, new_block )
					var new_block_timer : SceneTreeTimer = get_tree().create_timer( 0.33, true )
					assert( new_block_timer.connect( "timeout", self, "_on_delayed_fall_tick", [ new_block ] ) == OK )
				
				pass
			pass
		pass
	pass
					
	# Fall blocks
	for x in range( GridWidth ):
		for y in range( GridHeight ):
		
			var i = GridHeight - y - 1
			var block = get_block( x, i )
			if block != null && not is_instance_valid( block ):
				continue
				
			if block:	
				if block.is_swapping():
					is_swapping = block.is_swapping() || is_swapping
					block.mover.swap( delta )
				elif not block.scored:
					block.mover.fall( delta )
				
				#check if we're scored
				is_scoring = is_scoring || block.scored
				if y > highest_index:
					highest_index = min( y, DisplayHeight )
					
			pass
		pass
	pass

	# check for evaluation
	if _pending_evaluate:
		_pending_frames += 1
					
		if _pending_frames >= EVALUATE_BUFFER:
			evaluate_columns()
			evaluate_rows()
			var combo = scored_this_frame()
			if combo >= 3:
				player.emit_signal( "BlockCombo", player, combo )
			_pending_evaluate = false
			_pending_frames = 0
			
		pass
	pass
					
	# check for deletes
	for x in range( GridWidth ):
		
		for y in range( GridHeight ):
			
			var block = get_block( x, y )
			if block && block.pending_delete:
				set_block( x, y, null )		
				free_block( block )
				
			pass
		pass
	pass
	

	# ascend the grid
	if not player.has_bonus_time():
		_ascend_timer.set_paused( false )
		if not _ascend_timer.is_stopped():
			set_position( get_position() - Vector2(0, ( Block.SIZE / _ascend_timer.get_wait_time() ) * delta) )
		
		if get_position().y < ( _start_position.y - Block.SIZE + 1 ) && _ascend_timer.is_stopped() && not is_swapping:
			ascend_grid()
			_ascend_timer.start()
	else:
		_ascend_timer.set_paused( true )
	pass
	
	# let the player know we're still scoring
	player.is_scoring = is_scoring
	#update_health(highest_index)
	
	pass # _physics_process()
	
	
func update_health( y : int ) -> void:
	var offset = 5.0
	var ceiling = DisplayHeight - offset
	if not _ascend_timer.is_stopped():
#warning-ignore:narrowing_conversion
		y += _ascend_timer.get_wait_time() - _ascend_timer.get_time_left()
	player._health.set_percent( min( max( 0, y - 2 ) / ceiling, ceiling ) )
	
	pass # update_health
	
	
func play() -> void:
	_ascend_timer.start()
	set_pending_evaluate()
	
	pass # play()
	
	
func end() -> void:
	_ascend_timer.stop()	
	
	pass # end()


func set_ascend_time( time : float ) -> void:	
	_ascend_timer.set_wait_time( time )

	pass # set_ascend_time()
			

func set_pending_evaluate() -> void:
	_pending_frames = 0
	_pending_evaluate = true
	
	pass # set_pending_evaluate()
			

func reset() -> void:
	
	# free all blocks in the grid
	for x in range( GridWidth ):
		for y in range( GridHeight ):
			if _blockMatrix[x][y]:
				free_block( _blockMatrix[x][y] )
			_blockMatrix[x][y] = null
		pass
	pass
			
	# fill the incoming blocks
	fill_incoming_blocks()
	
	for child in get_children():
		match child.get_name():
			"cursor_controller","block_queue", "floor":
				break
			_:
				print( "Error: Block still exists after reset" )
				breakpoint
				assert( 0 )
		pass
	pass
	
	set_position( _start_position )
	end()
	
	pass # reset()
			

func get_bottom_xy() -> Vector2:
	return get_position() + Vector2(
		GridWidth * Block.SIZE,
		GridHeight * Block.SIZE )


# takes another block_grid and copies it
func copy_from_grid( block_grid : Node2D ) -> void:
	
	reset()
	for x in range( GridWidth ):
		for y in range( GridHeight ):
			var grid_block = block_grid.get_block( x, y )
			if grid_block:
				var block = create_block( grid_block.Type )
				block.set_position( Vector2( x * Block.SIZE, y * Block.SIZE ) )
				block.mover.Landed = true
				set_block( x, y, block )
				
	pass # copy_from_grid()


func fill_rows( rows : int ) -> void:
	
	reset()
	var refill = true
	while refill:
		for y in range( GridHeight - rows, GridHeight ):
			for x in range( GridWidth ):
				var block = get_block( x, y )
				var new_type = PlayerHelper.get_random_blocktype()
				if block:
					block.set_blocktype( new_type )
				else:
					block = create_block( new_type )
					block.set_position( Vector2( x * Block.SIZE, y * Block.SIZE ) )
					block.land( false )
				block.scored_this_frame = false
				set_block( x, y, block )
			pass
		pass
		
		evaluate_columns()
		evaluate_rows()
		refill = false
		
		for y in range( GridHeight - rows, GridHeight ):
			for x in range( GridWidth ):
				var block = get_block( x, y )
				if  block && block.scored_this_frame:
					refill = true
			pass
		pass
	
	_scored_this_frame = 0 # gotta reset this or games refill with pending score
	#update_health(rows-1)
	
	pass # fill_rows()
	
	
func fill_incoming_blocks() -> void:
	
	for i in range( GridWidth ):
		var new_block = _incoming_blocks[i] if _incoming_blocks[i] else create_block( PlayerHelper.BLOCKTYPES.RED )
		new_block.mover.Freeze = true
		new_block.set_position( Vector2( i, GridHeight ) * Block.SIZE )
		new_block.set_blocktype( PlayerHelper.get_random_blocktype() )
		new_block.sprite.set_material( DarkMaterial )
		new_block.set_name( "incoming_block_" + String( i ) )
		_incoming_blocks[i] = new_block
	
	pass # fill_incoming_blocks()

	
func create_block( type: int ) -> Node2D:
	
	var newBlock = BlockScene.instance()
	add_child( newBlock )
	newBlock.set_blocktype( type )
	newBlock.set_name( "block" )
	newBlock.set_position( vOFFSCREEN )
	newBlock.set_z_as_relative( false )
	newBlock.set_z_index( 0 )
	newBlock.mover.Landed = true
	newBlock.connect( "BlockLanded", player, "_on_block_landed" )
	
	return newBlock # create_block()


func create_full_block() -> Node2D:
	
	var newBlock = FullBlockScene.instance()
	add_child( newBlock )
	newBlock.set_blocktype( PlayerHelper.BLOCKTYPES.FULL )
	newBlock.set_name( "full_block" )
	newBlock.set_position( vOFFSCREEN )
	newBlock.set_z_as_relative( false )
	newBlock.set_z_index( 0 )
	newBlock.mover.Landed = true
	newBlock.connect( "BlockLanded", player, "_on_block_landed" )
	
	return newBlock # create_full_block()


func free_block( block : Node2D ) -> void:
	
	if not block ||  not is_instance_valid( block ) || not block.get_parent():
		return
	
	if block.is_connected( "BlockLanded", player, "_on_block_landed" ):
		block.disconnect( "BlockLanded", player, "_on_block_landed" )
	
	block.mover.set_target( null )
	
	#block.call_deferred('free')
	remove_child( block )
	block.queue_free()
	
	pass # free_block()


func get_block( x : int, y : int ) -> Node2D:
	return _blockMatrix[x][y]


func set_block( x : int, y : int, block : Node2D ) -> void:
	
	_blockMatrix[x][y] = block
	if block:
		block.grid_indices[0] = x
		block.grid_indices[1] = y
		block.build_name()
		
	pass # set_block()
		

func is_block_empty( x : int, y : int ) -> bool:
	return _blockMatrix[x][y] != null


# TODO:
# This should literally just freeze blocks
# VersusPlay should control the winning / loser fx
# VersusPlay should also account for ties
func freeze_blocks( player_won : bool ) -> void:
	
#	var impulse_position : Vector2 = $floor.get_global_position() + Vector2(56,0)
#	update_health(0 if player_won else 1)
	
	for x in range( GridWidth ):
		for y in range( GridHeight ):
			var index = GridHeight - 1 - y
			var block = get_block( x, index )
			if block:
				block.mover.Landed = true
				if not player_won:
					set_block( x, index, null )
					block.set_blocktype( block.Type, "_death" )
					
					if y > DisplayHeight:
						block.queue_free()
					elif  block.Type != PlayerHelper.BLOCKTYPES.FULL || x == 0:
						var loser_mover = LoserMove.instance()
						block.add_child( loser_mover )
						loser_mover.direction = Vector2( 0, 1 )
						loser_mover.delay = 0.05 + y * 0.05
				else:
					block.sprite.animation = "weener"
					block.sprite.set_frame( randi() % 6 )
					# todo: maybe find out if these materials need to be cleaned properly if unassigned
					var winner_material = BlinkMaterial.duplicate()
					winner_material.set_shader_param( "offset", rand_range( 0.0, 3.0 ) )
					block.sprite.set_material( winner_material )
					
	for i in range( GridWidth ):
		var block = _incoming_blocks[i]
		if block:
			if not player_won:
				_incoming_blocks[i] = null
				block.set_blocktype( block.Type, "_death" )
				
				var loser_mover = LoserMove.instance()
				block.add_child( loser_mover )
				loser_mover.direction = Vector2( 0, 1 )
			else:
				block.sprite.animation = "weener"
				block.sprite.set_frame( randi() % 6 )
				var winner_material = BlinkMaterial.duplicate()
				winner_material.set_shader_param( "offset", rand_range( 0.0, 3.0 ) )
				block.sprite.set_material( winner_material )
			
	pass # freeze_blocks()
		


func ascend_grid() -> void:
	# move all blocks up a row
	for y in range( 1, GridHeight ):
		for x in range( GridWidth ):
			var block = get_block( x, y )
			if block:
				var y_index = block.grid_indices[1] - 1
				if block.Type == PlayerHelper.BLOCKTYPES.FULL && x == 0:
					# we need to move full width blocks
					for i in range( GridWidth ):
						var x_index = GridWidth - i - 1
						set_block( x_index, y, null )
						set_block( x_index, y_index, block )
					block.set_position( Vector2( block.grid_indices[0], block.grid_indices[1] ) * Block.SIZE )
				elif block.Type != PlayerHelper.BLOCKTYPES.FULL:
					set_block( x, y, null )
					set_block( block.grid_indices[0], y_index, block )
					block.set_position( Vector2( block.grid_indices[0], block.grid_indices[1] ) * Block.SIZE )
				
	for i in range( GridWidth ):
		var new_block = _incoming_blocks[i]
		new_block.mover.Landed = true
		new_block.mover.Freeze = false
		set_block( i, GridHeight-1, new_block )
		new_block.set_position( Vector2( i, GridHeight-1 ) * Block.SIZE )
		new_block.sprite.set_material( new_block.default_material )

		var incoming_block = create_block( PlayerHelper.get_random_blocktype() )
		incoming_block.mover.Freeze = true
		incoming_block.set_position( Vector2( i, GridHeight ) * Block.SIZE )
		incoming_block.sprite.set_material( DarkMaterial )
		incoming_block.set_name( "incoming_block_" + String( i ) )
		_incoming_blocks[i] = incoming_block
	
	set_position( _start_position )
	$cursor_controller.translate_cursors( Vector2( 0, -1 ) )
	player._on_block_landed( false )
	set_pending_evaluate()
	player._on_evaluate()
	
	pass # ascend_grid()
	

# -------------------------------------------------------------------------------------------------
func evaluate_columns() -> void:
	for x in range( GridWidth ):
		var count = -1
		var compareBlock = null
		for y in range( GridHeight ):
			# Search from the bottom to top
			# if we hit an empty block, terminate early
			var yIndex = GridHeight - 1 - y
			var block = get_block( x, yIndex )
			
			if y == 0:
				# start the count at the bottom
				count = 1
			
			else:
				if not block:
					# this block is empty, count
					if count > 2:
						_scored_this_frame += count
						for i in range( count ):
							get_block( x, yIndex + ( i + 1 ) ).score_this_frame()

					count = 0

				elif compareBlock != null \
					&& block.Type == compareBlock.Type \
					&& not block.mover.Freeze && not compareBlock.mover.Freeze \
					&& block.mover.Landed && compareBlock.mover.Landed \
					&& not block.scored && not compareBlock.scored \
					&& not block.pending_delete && not compareBlock.pending_delete \
					&& block.Type < PlayerHelper.BLOCKTYPES.SPECIAL \
					&& not block.is_swapping() && not compareBlock.is_swapping():
					# count the block
					count += 1
				
				else:
					# couldnt satisfy conditions, break the count
					# TODO, find out why this case happens
					if count > 2:
						_scored_this_frame += count
						for i in range( count ):
							get_block( x, yIndex + ( i + 1 ) ).score_this_frame()
							
					count = 1
				
			# finished iterating upwards, 
			if yIndex == 0 && count > 2:
				_scored_this_frame += count
				for i in range( count ):
					get_block( x, i ).score_this_frame()

			# keep track of last block
			compareBlock = block
			
		pass # for x in Gridwidth
	pass # for y in GridHeight
		
	pass # evaluate_columns()


func evaluate_rows() -> void:
	
	for y in range( GridHeight ):
		var count = -1
		var compareBlock = null
		for x in range( GridWidth ):
			# iterate [0][.][..][n]
			var block = get_block( x, y )

			if not compareBlock:
				# compare was empty, restart
				count = 1
			
			else:
				if not block:
					# block is empty or at the right wall, count
					if count > 2:
						_scored_this_frame += count
						for i in range( count ):
							get_block( x - 1 - i, y ).score_this_frame()
					count = 0
				
				elif compareBlock != null \
					&& block.Type == compareBlock.Type \
					&& not block.mover.Freeze && not compareBlock.mover.Freeze \
					&& block.mover.Landed && compareBlock.mover.Landed \
					&& not block.scored && not compareBlock.scored \
					&& not block.pending_delete && not compareBlock.pending_delete \
					&& block.Type < PlayerHelper.BLOCKTYPES.SPECIAL \
					&& not block.is_swapping() && not compareBlock.is_swapping():
					# count the block
					count += 1
				
				else:
					# couldnt satisfy conditions, break the count
					if count > 2:
						_scored_this_frame += count
						for i in range( count ):
							get_block( x - 1 - i, y ).score_this_frame()
					count = 1
					
				pass
			pass

			# we reached the wall, count
			if x == GridWidth - 1 && count > 2:
				_scored_this_frame += count
				for i in range( count ):
					get_block( x - i, y ).score_this_frame()

			# keep track of last block
			compareBlock = block
			
		pass # for x in Gridwidth
	pass # for y in GridHeight
		
	pass # evaluate_rows()


func scored_this_frame() -> int:
	var score = _scored_this_frame
	
	for x in range( GridWidth ):
		for y in range( GridHeight ):
			var block = get_block( x, y )
			if block && block.scored_this_frame:
				block.score()
				block.scored = true
				block.combo_count = score

				# -- Search above and below for grouped block
				if y > 0:
					var top = get_block( x, y - 1 )
					if top && not top.scored && top.Type == PlayerHelper.BLOCKTYPES.FULL:
						top.score()

				if y < GridHeight - 1:
					var bottom = get_block( x, y + 1 )
					if bottom && not bottom.scored && bottom.Type == PlayerHelper.BLOCKTYPES.FULL:
						bottom.score()
			pass
		pass

	_scored_this_frame = 0
	
	return score # scored_this_frame()


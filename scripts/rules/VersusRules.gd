# VERSUS RULES
#
extends Node

const CountdownScene	= preload( "res://scenes/player/start_countdown.tscn" )
const ScoreFX			= preload( "res://scenes/fx/score_particle.tscn" )
const AvatarFX			= preload( "res://scenes/fx/avatar_particle.tscn" )
const Transition		= preload( "res://scenes/transition_sprite.tscn" )
const BlockQueue		= preload( "res://scripts/block/BlockQueue.gd" )
const MenuScene			= preload( "res://scenes/post_game_menu.tscn" )


## PLAYER HOOK SIGNALS
enum FUNC_FIELDS {
	NODE_SIGNAL,	# SIGNAL NAME
	NODE_FUNC,		# NODE FUNCTION NAME
	NODE_PATH		# RELATIVE TO A PLAYER NODE
}

const FUNC_LIST = [
	[ "PlayerLost", "_on_player_lost", "." ],
	[ "BlockCombo", "_on_block_combo", "." ],
	[ "ScoreComplete", "_on_score_particle_complete", "." ],
	[ "MultiplierCollect", "_on_player_multiplier_collect", "./multiplier" ]
]

var _start_timer 			:= Timer.new()
var _intro_delay_timer		:= Timer.new()
var _transition_delay_timer	:= Timer.new()
var _transition	: Node2D	= null
var _is_quitting : bool		= false
var _running : bool			= false

signal StartMenu
signal GameRematch

## ----------------------------------------------------------------------
## ScreenTransition Block
	
func _on_screen_transition_in() -> void:
	_transition_delay_timer.start()
	
	if not _is_quitting:
			emit_signal( "GameRematch" )
	
	pass # _on_screen_transition_in()
	
	
func _on_transition_delay() -> void:
	_transition.transition_out()

	if _is_quitting:
		emit_signal( "StartMenu" )
		_is_quitting = false
	else:
		reset_game()
	
	pass # _on_transition_delay()
	
		
func _on_screen_transition_out() -> void:
	_transition.disconnect( "TransitionIn", self, "_on_screen_transition_in" )
	_transition.disconnect( "TransitionOut", self, "_on_screen_transition_out" )

	get_parent().remove_child( _transition )
	_transition.queue_free()
	_transition = null

	pass # _on_screen_tranisition_out()
	
## ----------------------------------------------------------------------


func _ready() -> void:
	add_child( _transition_delay_timer )
	assert( _transition_delay_timer.connect( "timeout", self, "_on_transition_delay" ) == OK )
	_transition_delay_timer.set_wait_time( 0.5 )
	_transition_delay_timer.set_one_shot( true )
	_transition_delay_timer.set_name( "transition_delay_timer" )

	add_child( _intro_delay_timer )
	_intro_delay_timer.set_wait_time( 1.0 )
	_intro_delay_timer.set_one_shot( true )
	assert( _intro_delay_timer.connect( "timeout", self, "_on_intro_tick" ) == OK )
	_intro_delay_timer.set_name( "intro_delay_timer" )

	add_child( _start_timer )
	_start_timer.set_wait_time( 3.0 )
	_start_timer.set_one_shot( true )
	assert( _start_timer.connect( "timeout", self, "_on_start_tick" ) == OK )
	_start_timer.set_name( "start_timer" )
	
	pass # _ready()
	

func _hook_player( player : Node2D ) -> void:
	for tuple in FUNC_LIST:
		if not has_method( tuple[FUNC_FIELDS.NODE_FUNC] ):
			printerr( "ERROR:_hook_player(", player.get_name(), "): VersusRules invalid function: \"", tuple[FUNC_FIELDS.NODE_FUNC], "\"" )
			continue

		if not player.has_node( tuple[FUNC_FIELDS.NODE_PATH] ):
			printerr( "ERROR:_hook_player(", player.get_name(), "): No valid node at path: \"", tuple[FUNC_FIELDS.NODE_PATH], "\"" )
			continue

		var node_to_hook = player.get_node( tuple[FUNC_FIELDS.NODE_PATH] )
		if not node_to_hook.get_script().has_script_signal( tuple[FUNC_FIELDS.NODE_SIGNAL] ):
			printerr( "ERROR:_hook_player(", player.get_name(), "): Class [", node_to_hook.get_name(), "] has no signal: \"", tuple[FUNC_FIELDS.NODE_SIGNAL], "\"" )
			continue

		if node_to_hook.is_connected( tuple[FUNC_FIELDS.NODE_SIGNAL], self, tuple[FUNC_FIELDS.NODE_FUNC] ):
			node_to_hook.disconnect( tuple[FUNC_FIELDS.NODE_SIGNAL], self, tuple[FUNC_FIELDS.NODE_FUNC] )
		
		assert( node_to_hook.connect( tuple[FUNC_FIELDS.NODE_SIGNAL], self, tuple[FUNC_FIELDS.NODE_FUNC] ) == OK )
		
	pass # _hook_player()
	

func _on_intro_tick() -> void:
	var countdown = CountdownScene.instance()
	add_child( countdown )
	countdown.set_position( Vector2( 160,100 ) )
	_start_timer.start()
	
	pass # _on_intro_tick()


func _on_start_tick() -> void:
	$player_1.play()
	$player_2.play()
	_running = true
	
	pass # _on_start_tick()


## VERSUS FUNCTIONS
func _on_player_multiplier_collect( player : Node2D, multi : int ) -> void:
	for i in range( multi ):
		player.block_queue.add_data(
				PlayerHelper.BLOCKTYPES.SPECIAL,
				BlockQueue.FULL,
				-1,
				0.25 + i * 0.15)
				
	pass # _on_player_multiplier_collect()


func _on_block_combo( player : Node2D, count : int ) -> void:
	# add bonus time to player
	player.add_bonus_time( count )
	
	# add multiplier to opponent
	var opponent = PlayerHelper.get_opponent( player )
	if count < 4:
		opponent.block_queue.add_data(
				PlayerHelper.get_random_blocktype(),
				BlockQueue.SINGLE,
				count - 1,
				1.25 )
	else:
		var new_multi : int = opponent.multiplier.count
#warning-ignore:integer_division
		new_multi += count /  4
		opponent.multiplier.set_count( new_multi )
		opponent.multiplier.focus_and_play()
		
	pass # _on_block_combo()


# TODO:
#	this should be removed in favor of avatar reactions
func _on_score_particle_complete( player : Node2D ):
	var opponent = PlayerHelper.get_opponent( player )
	var dir = Vector2( 1, 0 )
	if PlayerHelper.is_player_1( opponent ):
		dir.x *= -1
		
	pass # _on_score_particle_complete()


func _on_player_lost( loser : Node2D ) -> void:
	var players = [ $player_1, $player_2 ]
	for player in players:
		player.end_game( player != loser )
		if player == loser:
			var menu = MenuScene.instance()
			player.add_child( menu )
			menu.set_position( player.get_node("menu_location").get_position() )
			menu.set_input( player.get_input_class() )
			menu.connect( "MenuChoice", self, "_on_loser_menu_choice" )
		
	_running = false
	
	pass # _on_player_lost()
	
	
func _on_loser_menu_choice( menu : Node2D, index : int ) -> void:
	if menu.is_visible():
		var player = menu.get_parent()
		player.remove_child( menu )
		menu.queue_free()
		
		var opponent = PlayerHelper.get_opponent( player )
		if opponent.has_node( "/post_game_menu" ):
			var opponent_menu = opponent.get_node( "/post_game_menu" )
			opponent.remove_child( opponent_menu )
			opponent_menu.queue_free()
		
		if index > 0:
			_is_quitting = true
		
		_transition = Transition.instance()
		get_parent().add_child( _transition )
		_transition.set_name( get_name() + "_transition" )
		_transition.transition_in()
		assert( _transition.connect( "TransitionIn", self, "_on_screen_transition_in" ) == OK )
		assert( _transition.connect( "TransitionOut", self, "_on_screen_transition_out" ) == OK )

	pass # _on_loser_menu_choice()


func begin_game() -> void:
	_hook_player( $player_1 )
	_hook_player( $player_2 )
	
	$player_1.cursor.set_input( PlayerHelper.PlayerInputList[0] )
	$player_2.cursor.set_input( PlayerHelper.PlayerInputList[1] )

	$player_2.is_puppet = true

	# reset grids
	reset_game()
	
	pass # begin_game()
	
	
func reset_game() -> void:
	$player_1.new_game()
	$player_2.new_game()
	$player_2.block_grid.copy_from_grid( $player_1.block_grid )

	_intro_delay_timer.start()

	pass # reset_game()


# A scored block on a player has completed its score fx
#	>3 Combo: add an avatar particle to opponent multiplier
#	<=3 Combo: add a score particle to opponent board
func on_block_fx_complete( player : Node2D, fx : Node2D, block : Node2D ) -> void:
	var opponent = PlayerHelper.get_opponent( player )

	var new_particle = null
	if block.combo_count > 3:
		new_particle = AvatarFX.instance()
	else:
		new_particle = ScoreFX.instance()

	opponent.add_child( new_particle )
	new_particle.color = fx.color
	new_particle.set_global_position( fx.get_global_position() )
	new_particle.init()
	new_particle.connect( "Complete", player, "_on_score_particle_complete" )
	block.pending_delete = true
	
	pass # on_block_fx_complete()


func on_full_block_fx_complete( block : Node2D ) -> void:
	block.pending_delete = true
	
	pass # on_full_block_fx_complete()


# TODO:
#	is this func necessary?
func disconnect_particle( particle : Node2D ) -> void:
	particle.disconnect( "Complete", self, "_on_score_particle_complete" )
	
	pass # disconnect_particle()

		

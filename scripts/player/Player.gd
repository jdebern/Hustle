# PLAYER
#
extends Node

# Player helpers
# # const PlayerHelper = preload("res://scripts/helpers/PlayerHelper.gd")
# Block script
const Block = preload("res://scripts/block/Block.gd")
# Queue
const BlockQueue = preload("res://scripts/block/BlockQueue.gd")

# Public vars
onready var multiplier : Node2D		= get_node("multiplier")
onready var pinger : Node			= get_node("pinger")
onready var block_grid : Node2D		= get_node("block_grid")
onready var block_queue : Node	= get_node("block_grid/block_queue")
onready var cursor : Node2D			= get_node("block_grid/cursor_controller")
var game_over : bool	= false
var is_scoring : bool	= false
var is_puppet : bool	= false # Determines if this player intends to copy a grid from another

export(float) var bonus_seconds = 0.4;

# Private vars
var _evaluate_timer = Timer.new()
var _score_complete = false
var _evaluate = false
var _ticks = 0
var _bonus_time = 0
var _bonus_scaling = [ 1, 1, 1, 1.6, 2.0, 2.5 ]
var _health = null

# Signals
signal PlayerScored
signal PlayerLost
signal BlockCombo
signal BlockFX
signal FullBlockFX
signal ScoreComplete


func _ready():
	add_child(_evaluate_timer)
	_evaluate_timer.set_wait_time(0.5)
	_evaluate_timer.set_one_shot(true)
	_evaluate_timer.connect("timeout", self, "_on_evaluate")
	_evaluate_timer.set_name("evaluate_timer")

	pass # _ready()


func _physics_process(delta):
	if _score_complete:
		_score_complete = false
		emit_signal("ScoreComplete", self)
	
	if is_scoring:
		_bonus_time = max(_bonus_time, 1)
	else:	
		_bonus_time = max(_bonus_time - delta, 0)

	pass # _physics_process()
	
	
func _on_evaluate():
	if not has_bonus_time():
			for x in range(block_grid.GridWidth):
				var block = block_grid.get_block(x, block_grid.DisplayHeight)
				if block && block.mover.Landed:
					emit_signal("PlayerLost", self)
					break

	pass # _on_evaluate()


func _on_block_landed(ping):
	_evaluate_timer.stop()
	_evaluate_timer.start()
	
	if ping:
		pinger.ping(Vector2(0,1), 8.0, 0.05)

	pass # _on_block_landed()


func _on_score_particle_complete(particle):
	particle.disconnect("Complete", self, "_on_score_particle_complete")
	_score_complete = true

	pass # _on_score_particle_complete()
	
	
func new_game():
	block_grid.reset()
	if !is_puppet:
		block_grid.fill_rows(PlayerHelper.get_starting_rows())

	block_grid.set_ascend_time(PlayerHelper.get_ascend_time())
	
	cursor.reset()

	pass # new_game()
	

func play():
	cursor.set_frozen(false)
	block_grid.play()
	game_over = false

	pass # play()
	

func add_bonus_time(blocks_scored):
	var score = min(blocks_scored, _bonus_scaling.size() - 1)
	_bonus_time += bonus_seconds * _bonus_scaling[score]

	pass # add_bonus_time()
	
	
func has_bonus_time():

	return _bonus_time > 0


func end_game(player_won):
	game_over = true
	block_grid.end()
	block_grid.freeze_blocks(player_won)
	block_queue.clear_queue()
	cursor.set_frozen(true)
	cursor.set_visible(false)

	pass # end_game()
	

func ping(direction, force, lifetime):
	pinger.ping(direction, force, lifetime)

	pass # ping()
	
	
func get_input_class():

	return cursor.player_input

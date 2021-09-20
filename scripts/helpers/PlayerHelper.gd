# PLAYER HELPER
#	- Helper functions for player objects
# 
extends Node

const BlockSpriteFrames = preload( "res://animations/game_blocks.tres" )
const BlockGridMask = preload( "res://materials/masked_material.tres" )

# Constants
enum BLOCKTYPES {
	BLUE,
	GREEN,
	PURPLE,
	YELLOW,
	ORANGE,
	RED,
	SPECIAL,
	FULL,
	COUNT,
	POOL
}

enum BLOCKSTATE {
	READY,		 # -- Newly spawned from full block, ready to fall
	FALLING,	 # -- Active falling block
	FROZEN,		 # -- Frozen block
	SCORED,		 # -- Scored block
	FULL_SCORED, # -- Full block scored
}

const ANIM_LOOKUP = {
	BLOCKTYPES.BLUE		: "blue",
	BLOCKTYPES.GREEN	: "green",
	BLOCKTYPES.PURPLE	: "purple",
	BLOCKTYPES.YELLOW	: "yellow",
	BLOCKTYPES.ORANGE	: "orange",
	BLOCKTYPES.RED		: "red",
	BLOCKTYPES.SPECIAL	: "special",
	BLOCKTYPES.FULL		: "full"
}

const SCORE_TIMES = [
	0.8, # <= 3 blocks
	1.2, # 4 blocks
	1.6, # 5 blocks
	2.0, # >= 6 blocks
]

const ASCEND_TIMES = [
	7.5, # slow
	4.0, # normal
	2.0, # extreme
]

class Colors:
	enum {
		BLUE,
		GREEN,
		PURPLE,
		YELLOW,
		ORANGE,
		RED,
		SPECIAL,
		COUNT
	}
	
class PlayerInput:
	var up : String		= "ui_up"
	var down : String	= "ui_down"
	var left : String	= "ui_left"
	var right : String	= "ui_right"
	var swap : String	= "ui_select"
	
var Difficulty : int
var ColorCount : int
var PlayerInputList = []


func _ready():
	Difficulty = 0
	ColorCount = 0

	var input = PlayerHelper.PlayerInput.new()
	var input_p2 = PlayerHelper.PlayerInput.new()
	
	input.up = "p2_up"
	input.left = "p2_left"
	input.right = "p2_right"
	input.down = "p2_down"
	input.swap = "p2_swap"
	
	PlayerInputList.resize ( 2 )
	PlayerInputList[ 0 ] = input
	PlayerInputList[ 1 ] = input_p2
	
	pass # _ready()
	

func get_starting_rows():
	return Difficulty + 3
	
	pass # get_starting_rows()


func get_ascend_time():
	return ASCEND_TIMES[ Difficulty ]

	pass # get_ascend_time()


func get_random_blocktype():
	return randi() % ( PlayerHelper.ColorCount + 1 )

	pass # get_random_blocktype()


static func get_score_time( index ):
	return SCORE_TIMES[ index ]

	pass # get_score_times()

	
static func get_opponent( player ):
	var player_1 = player.get_node( "../player_1" )
	var player_2 = player.get_node( "../player_2" )
	if player_1.get_name() == player.get_name():
		return player_2
	else:
		return player_1
		
	pass # get_opponent()


static func is_player_1( player ):
	return player.get_name() == "player_1"
	
	pass # is_player_1()
	
	
func spawn_scored_fullblock( parent : Node2D, time : float, position : Vector2 ) -> void:
	var sprite = ClassDB.instance( "AnimatedSprite" )
	sprite.set_sprite_frames( BlockSpriteFrames )
	sprite.set_animation( "full_death" )
	sprite.set_material( BlockGridMask )
	sprite.set_position( position )
	sprite.set_centered( false )
	
	parent.add_child( sprite )
	
	yield( get_tree().create_timer( time ), "timeout" )
	
	sprite.queue_free()
	
	pass # spawn_scored_fullblock()
	
	
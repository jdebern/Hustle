# CURSOR CONTROL
extends Node2D

# Block script (to steal the SIZE)
var Block = preload( "res://scripts/Block.gd" )

# Public Vars
enum {
	LEFT,
	RIGHT
}

# Private vars
var _gridDimensions := Vector2( 0, 0 )
var _gridVectors 	:= [ Vector2( 0, 0 ), Vector2( 1, 0 ) ]
var _cursors		:= [ ]


func _ready() -> void:
	var player = get_parent()
	_gridDimensions = Vector2( player.GridWidth, player.GridHeight )
	_cursors[ LEFT ] = get_node( "cursor_a" )
	_cursors[ RIGHT ] = get_node( "cursor_b" )
	_align_to_grid()

	pass # _ready()


func _process( delta : float ) -> void:
	var inputStep = Vector2( 0, 0 )
	if Input.is_action_just_pressed( "ui_right" ):
		inputStep.x = 1
	elif Input.is_action_just_pressed( "ui_left" ):
		inputStep.x = -1
	elif Input.is_action_just_pressed( "ui_up" ):
		inputStep.y = -1
	elif Input.is_action_just_pressed( "ui_down" ):
		inputStep.y = 1
	
	if inputStep != Vector2( 0, 0 ):
		translate_cursors( inputStep )
		
	pass # _process()


func _align_to_grid() -> void:
	for i in range( 2 ):
		_cursors[i].set_position(\
			Vector2( ( _gridVectors[i].x * Block.SIZE ) + ( Block.SIZE * 0.5 ),\
			( _gridVectors[i].y * Block.SIZE ) + ( Block.SIZE * 0.5 ) ) )
			
	pass # _alignToGrid()


func translate_cursors( translation : Vector2 ) -> void:
	var newVectors = \
		[ _gridVectors[ LEFT ] + translation , _gridVectors[ RIGHT ] + translation ]
		
	for i in range( 2 ):
		if newVectors[i].x >= _gridDimensions.x \
			|| newVectors[i].y >= _gridDimensions.y \
			|| newVectors[i].y < 0 || newVectors[i].x < 0:
			return

	_gridVectors = newVectors
	_align_to_grid()
	for i in range( 2 ):
		_cursors[i].set_frame( 0 )
		_cursors[i].play()

	pass # translate_cursors()
	
	
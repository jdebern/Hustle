# GAME
#

extends Node2D

onready var title_image_material : ShaderMaterial = preload("res://materials/title_image_material.tres")

onready var play =		get_node( "screens/play" )
onready var title =		get_node( "screens/title_select" )
onready var options =	get_node( "screens/options" )

var backgrounds			:= Array()
var bg_index : int		= 0

func _ready() -> void:
	seed( OS.get_unix_time() )
	
	title.connect( "StartVersus", self, "_on_start_versus" )
	title.connect( "StartOptions", self, "_on_start_options" )

	options.connect( "StartMenu", self, "_on_start_menu" )
	options.reset( true )

	play.connect( "StartMenu", self, "_on_start_menu" )
	
	_screen_set_input( title, PlayerHelper.PlayerInputList[0] )
	_screen_set_input( options, PlayerHelper.PlayerInputList[0] )
	
	set_screen_active( title, true )
	
	backgrounds = [ $backgrounds/industrial, $backgrounds/forest, $backgrounds/mountains ]
	
	bg_index = randi() % backgrounds.size()
	set_background_index( bg_index )
	
	pass # _ready()


func _process( delta : float ) -> void:
	
	if Input.is_action_just_pressed( "ui_cancel" ):
		_on_play_GameRematch()

	pass # _process()


func _screen_set_input( screen : Node2D, input ) -> void:
	screen.player_input = input

	pass # _screen_set_input()
	

func _on_start_versus() -> void:
	set_screen_active( play, true )
	set_screen_active( options, false )
	set_screen_active( title, false )
	play.begin_game()

	pass # _on_start_versus()


func _on_start_options() -> void:
	set_screen_active( play, false )
	set_screen_active( options, true )
	set_screen_active( title, false )
	options.reset( false )

	pass # _on_start_options()
	

func _on_start_menu() -> void:
	set_screen_active( play, false )
	set_screen_active( options, false )
	set_screen_active( title, true )
	title.reset()

	pass # _on_start_menu()


func _on_play_GameRematch() -> void:
	bg_index = wrapi( bg_index + 1, 0, backgrounds.size() )
	set_background_index( bg_index )
		
	pass # Replace with function body.

## --------------------------------------------------------------

func set_screen_active( screen : Node2D, is_active : bool ) -> void:
	screen.set_process_input( is_active )
	screen.set_visible( is_active )

	pass # set_screen_active()
	
	
func set_background_index( index : int ) -> void:
	assert( index < backgrounds.size() )
	
	for node in backgrounds:
		node.set_visible( false )
		for child in node.get_children():
			var parallax := child as ParallaxTexture
			if parallax:
				parallax.Timescale *= -1.0
		
	backgrounds[ index ].set_visible( true )
	title_image_material.set_shader_param( "background_index", index );
	
	pass # set_background_index
	

# OPTIONS SCREEN
#	big ol handler of your stuff

extends Node2D

const Transition = preload( "res://scenes/transition_sprite.tscn" )

var _transition_delay_timer = Timer.new()
var _transition = null

var player_input = null

signal StartMenu

## ----------------------------------------------------------------------
## OptionsItem Block

enum ITEMTYPES {
	DIFFICULTY,
	SCALE,
	COLORS,
	BACK,
	
	COUNT
}


class OptionsItem:
	var name : String		= ""
	var index : int			= 0
	var num_elements : int	= 0
	var elements : Array	= []
	var position 			:= Vector2()

var options_items : Array	= []
var options_index : int		= 0


func create_options_item( node : Node2D, position : Vector2 ) -> OptionsItem:
	var item : OptionsItem = OptionsItem.new()
	item.name = node.get_name()
	item.elements = node.get_children()
	item.num_elements = item.elements.size()
	item.position = position
	
	return item
	

func update_options_item( item : OptionsItem, new_index : int ) -> void:	
	if item.name == "colors":
		update_colors_item( item, new_index )
	elif item.elements.size():
		item.elements[ item.index ].set_visible(false)
		item.index = (new_index + item.num_elements) % item.num_elements
		item.elements[ item.index ].set_visible(true)

	pass # update_options_item()


func update_colors_item( item : OptionsItem, new_index : int ) -> void:
	item.index = wrapi( new_index, 2, item.num_elements )
	for i in range( item.num_elements ):
		item.elements[ i ].set_visible( i <= item.index )

	pass # update_colors_item()

## ----------------------------------------------------------------------
## CursorBar Block

func update_cursor( index : int ) -> void:
	options_index = wrapi( index, 0, options_items.size() )
	var item : OptionsItem = options_items[ options_index ]
	assert( item )

	$cursors.set_position( item.position )

	pass # update_cursor()

## ----------------------------------------------------------------------
## ScreenTransition Block
	
func _on_screen_transition_in() -> void:
	_transition_delay_timer.start()
	
	pass # _on_screen_transition_in()
	
	
func _on_transition_delay() -> void:
	_transition.transition_out()
	emit_signal( "StartMenu" )
		
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
	_transition_delay_timer.connect( "timeout", self, "_on_transition_delay" )
	_transition_delay_timer.set_wait_time( 0.5 )
	_transition_delay_timer.set_one_shot( true )
	add_child( _transition_delay_timer )

	set_process_input( false )
	options_index = 0
	options_items.append( 
		create_options_item(
			get_node( "difficulty" ),
			get_node( "menu_locations/difficulty" ).get_position() ) )
	options_items.append( 
		create_options_item(
			get_node( "scale" ),
			get_node( "menu_locations/scale" ).get_position() ) )
	options_items.append( 
		create_options_item(
			get_node( "colors" ),
			get_node( "menu_locations/colors" ).get_position() ) )
	options_items.append(
		create_options_item(
			get_node( "back" ),
			get_node( "menu_locations/back" ).get_position() ) )

	pass # _ready()


func reset( apply : bool ) -> void:
	update_cursor( 0 )

	for item in options_items:
		for element in item.elements:
			element.set_visible( false )
		
		match item.name:
			"difficulty":
				update_options_item( item, PlayerHelper.Difficulty )
			"scale":
				update_options_item( item, WindowHelper.scale - 1)
			"colors":
				update_options_item( item, PlayerHelper.ColorCount )
		
		if item.num_elements > 0:
			item.elements[ item.index ].set_visible( true )
	
	if apply:
		_apply_options()

	pass # reset()


func _input( event : InputEvent ) -> void:

	var current_item : OptionsItem = options_items[ options_index ]

	if current_item:
		if event.is_action_pressed( player_input.left ):
			update_options_item( current_item, current_item.index - 1 )
		elif event.is_action_pressed( player_input.right ):
			update_options_item( current_item, current_item.index + 1 )

	if event.is_action_pressed( player_input.up ):
		update_cursor( options_index - 1 )
	elif event.is_action_pressed( player_input.down ):
		update_cursor( options_index + 1 )
	
	if event.is_action_pressed( player_input.swap ):
		_apply_options()
		if options_index == ITEMTYPES.BACK:
			_transition = Transition.instance()
			get_parent().add_child( _transition )
			_transition.set_name( get_name() + "_transition" )
			_transition.transition_in()
			assert( _transition.connect( "TransitionIn", self, "_on_screen_transition_in" ) == OK )
			assert( _transition.connect( "TransitionOut", self, "_on_screen_transition_out" ) == OK )
			set_process_input( false )

	pass # _input()

	
func _apply_options() -> void:
	for item in options_items:
		match item.name:
			"difficulty":
				apply_difficulty( item.index )
			"scale":
				apply_window_scale( item.index )
			"colors":
				apply_block_colors( item.index )

	pass # _apply_options()
	
	
func apply_difficulty( index : int ) -> void:
	PlayerHelper.Difficulty = index

	pass # apply_difficulty()
	
	
func apply_window_scale( index : int ) -> void:
	if index == 3:
		WindowHelper.set_fullscreen( true )
	else:
		WindowHelper.set_fullscreen( false )
		
	WindowHelper.new_window_scale( index + 1 )

	pass # apply_window_scale()
	
	
func apply_block_colors( index : int ) -> void:
	PlayerHelper.ColorCount = index

	pass # apply_block_colors()
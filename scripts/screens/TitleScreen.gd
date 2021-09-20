# TITLE SCREEN
#	Handles title drawing and buttons
#	Lack of documentation is killing me here

extends Node2D

const Transition = preload( "res://scenes/transition_sprite.tscn" )

enum {
	NONE,
	VERSUS,
	OPTIONS,
	EXIT,

	TRANSITION_IN,
	TRANSITION_IDLE,
	TRANSITION_OUT
}

const EASE_TIMES : Array	= [ 1.5, 1.7, 1.9, 1 ]
const TITLE_END  : Vector2	= Vector2( 450, -100 )
const TITLE_START : Vector2 = Vector2( 165, 60 )

var _rotation_offset : float		= 6 * PI * 2
var _idle_delta : float				= 0
var _transition_delta : float		= 0
var _transition_delay_timer : Timer	= Timer.new()
var _transition : Node				= null

var _mode			= NONE
var _state			= TRANSITION_IN
var player_input	= null

signal StartVersus
signal StartOptions


func _ready() -> void:
	assert( _transition_delay_timer.connect( "timeout", self, "_on_transition_delay" ) == OK )
	_transition_delay_timer.set_wait_time( 0.5 )
	_transition_delay_timer.set_one_shot( true )
	add_child( _transition_delay_timer )
	set_process_input( false )

	_state = TRANSITION_IDLE
	
	pass # _ready()

## ----------------------------------------------------------------------
## ScreenTransition Block
	
func _on_screen_transition_in() -> void:
	_transition_delay_timer.start()
	
	match _mode:
		VERSUS:
			emit_signal( "StartVersus" )
		EXIT:
			get_tree().quit()
		OPTIONS:
			emit_signal( "StartOptions" )
		_:
			pass

	pass # _on_screen_transition_in()
	
	
func _on_transition_delay() -> void:
	_transition.transition_out()
	
	pass # _on_transition_delay()
	
		
func _on_screen_transition_out() -> void:
	_transition.disconnect( "TransitionIn", self, "_on_screen_transition_in" )
	_transition.disconnect( "TransitionOut", self, "_on_screen_transition_out" )

	get_parent().remove_child( _transition )
	_transition.queue_free()
	_transition = null

	pass # _on_screen_tranisition_out()
	
## ----------------------------------------------------------------------


func _input( event : InputEvent ) -> void:
	if event.is_action_pressed( player_input.swap ):
		var action = $main_menu.get_menu_action()
		match action:
			"versus":
				set_mode( VERSUS )
			"options":
				set_mode( OPTIONS )
			_:
				set_mode( EXIT )
				
		_transition = Transition.instance()
		get_parent().add_child( _transition )
		_transition.set_name( get_name() + "_transition" )
		_transition.transition_in()
		assert( _transition.connect( "TransitionIn", self, "_on_screen_transition_in" ) == OK )
		assert( _transition.connect( "TransitionOut", self, "_on_screen_transition_out" ) == OK )

		set_process_input( false )

	elif event.is_action_pressed( player_input.up ):
		$main_menu.traverse_list( -1 )

	elif event.is_action_pressed( player_input.down ):
		$main_menu.traverse_list( 1 )
	
	pass #_input()


func _process( delta : float ) -> void:
	
	$title.set_visible( true )
	match _state:
		TRANSITION_IN:
			transition_in( delta )
		TRANSITION_IDLE:
			transition_idle( delta )
		TRANSITION_OUT:
			transition_out( delta )

	pass # _process()


func reset() -> void:
	$title.set_position( TITLE_START )
		
	_mode = 0
	_transition_delta = 0
	$main_menu.toggle_menu_item( 0 )
	_state = TRANSITION_IDLE
	
	pass # _reset()


func set_mode( mode ) -> void:
	_mode = mode
	_state = TRANSITION_OUT
	_transition_delta = 0
	
	pass # set_mode()


func transition_in( delta : float ) -> void:
	if _transition_delta <= EASE_TIMES[ 3 ]:
		# $title.set_position(MathHelper.lerp(TITLE_START, Vector2(165, 60), min(_transition_delta/EASE_TIMES[ 2 ],1)))
		_rotation_offset = MathHelper.lerp( PI*-3.5, 0, min(_transition_delta/EASE_TIMES[ 2 ], EASE_TIMES[ 2 ] ) )
		var scale = MathHelper.out_back( _transition_delta, 0.01, 0.54, EASE_TIMES[ 3 ], 1 )
		$title.set_scale( Vector2( scale, scale ) )
		# $title.set_rotation(_rotation_offset)

	_transition_delta += delta
	if _transition_delta > EASE_TIMES[ 2 ]:
		_state = TRANSITION_IDLE

	pass # transition_in()


func transition_idle( delta : float ) -> void:
	_idle_delta += delta
	$title.set_rotation( sin( _idle_delta ) * 0.13 )
	
	pass # transition_idle()
	

func transition_out( delta : float ) -> void:
	if _transition_delta <= EASE_TIMES[ 3 ]:
		$title.set_position( MathHelper.lerp( TITLE_START, TITLE_END, _transition_delta / EASE_TIMES[ 3 ] ) )
		_rotation_offset = MathHelper.out_back( _transition_delta, 0, PI * -4, EASE_TIMES[ 3 ], 0 )
		$title.set_rotation( _rotation_offset )

	_transition_delta += delta
	if _transition_delta > EASE_TIMES[ 2 ]:
		_state = TRANSITION_IDLE
		_mode = NONE
		_transition_delta = 0
		
	pass # transition_out()

	

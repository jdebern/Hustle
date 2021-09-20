extends Node2D

const SelectedMaterial = preload("res://materials/menu_item_selected.tres")

export(float) var speed = 1.5
export(float) var hidden_time = 1.5
var player_input = null

var _time = 0
var _index = 0
var _button_material = null
var _outline_color = Color(1.0, 0.0, 0.0, 1.0)
var _hide_timer = Timer.new()

signal MenuChoice

func _ready():
	_time = 0
	_index = 0
	update_text()
	
	_hide_timer.set_one_shot(true)
	_hide_timer.set_wait_time(hidden_time)
	add_child(_hide_timer)
	_hide_timer.start()
	_hide_timer.set_name("hide_timer")
	set_visible(false)
	
	_outline_color = _button_material.get_shader_param("outline_color")
	pass

func _process(delta):
	if _hide_timer.is_stopped():
		set_visible(true)
	
	#selected item shader	
	_time += delta * speed
	var real_hue = _outline_color.h + (1+sin(_time)*0.5);
	var real_color = _outline_color;
	real_color.h = real_hue;
	_button_material.set_shader_param("outline_color", real_color)
	
	if is_visible():
		if Input.is_action_just_pressed(player_input.swap):
			emit_signal("MenuChoice", self, _index)
		elif Input.is_action_just_pressed(player_input.up) || Input.is_action_just_pressed(player_input.down):
			_index = (_index + 1) % 2
			update_text()
	pass
	
	
func _get_selected_button():
	return $rematch_button if _index == 0 else $quit_button
	
	
func update_text():
	$rematch_button.set_material( SelectedMaterial if _index == 0 else null )
	$quit_button.set_material( SelectedMaterial if _index > 0 else null )
	_button_material = _get_selected_button().get_material()
	pass
	
		
func set_input(new_input):
	player_input = new_input
	pass
	
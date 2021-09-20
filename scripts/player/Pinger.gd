# PINGER
#	- HEH
extends Node

var MathHelper = preload( "res://scripts/helpers/MathHelper.gd" )

onready var _start_position = get_parent().get_position()
onready var _target_node : Node2D = get_parent()#get_node( "../block_grid" )
var _offset = Vector2()
var _lifetime = 0.5
var _time = 0

func _ready():
	set_process( false )
	
	pass # _ready

func ping( direction : Vector2, force : float, lifetime : float ):
	_lifetime = lifetime
	_time = 0
	_offset = direction * force
	_target_node.set_position( _start_position + _offset )
	set_process(true)

	pass # ping

func _process( delta : float ):
	_time += delta
	
	if _time >= _lifetime:
		_target_node.set_position( _start_position )
		set_process( false )
	else:
		var pos = _target_node.get_position()
		pos.x = MathHelper.out_cubic( _time, _start_position.x + _offset.x, -_offset.x, 1.0 )
		pos.y = MathHelper.out_cubic( _time, _start_position.y + _offset.y, -_offset.y, 1.0 )
		_target_node.set_position( pos )

	pass # _process
	

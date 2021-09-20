# BLOCK
#

extends Node2D

# Score fx
const ScoreFX		= preload( "res://scenes/fx/score_particle_system.tscn" )
const ScoreShader	= preload( "res://materials/contrast_blink_material.tres" )
const Filler		= preload( "res://scenes/block/full_block_filler.tscn" )

# Private vars
var _sprite_data = [
	"",		# animation name
	0,		# frame index
]

# Public vars
export( Material ) var default_material : Material = null

const SIZE : int				= 20
var Type : int					= 0

var combo_count : int			= 0
var scored : bool				= false
var scored_this_frame : bool	= false
var pending_delete : bool		= false
var grid_indices : Array		= [ 0, 0 ]
var state : int					= PlayerHelper.BLOCKSTATE.FROZEN

onready var mover : Node			= $block_mover
onready var sprite : AnimatedSprite = $sprite

signal BlockLanded
signal BlockScored


func _ready() -> void:
	pending_delete = false
	combo_count = 0
	grid_indices[0] = 0
	grid_indices[1] = 0
	$sprite.set_material( default_material )
	
	pass # _ready()


# returns whether block is swapping to Target
func is_swapping() -> bool:
	return $block_mover.TargetPosition != null
	
	pass # is_swapping()


# Sets the BLOCKTYPE of this block
func set_blocktype( type : int, animSuffix : String = "", frameIndex : int = 0 ) -> void:
	Type = type

	if animSuffix != "":
		_sprite_data[0] = String( PlayerHelper.ANIM_LOOKUP[Type] + animSuffix )
		_sprite_data[1] = frameIndex
	else:
		_sprite_data[0] = "%s_idle" % PlayerHelper.ANIM_LOOKUP[Type]
		_sprite_data[1] = ( randi() % ( 9 - 4 ) ) + 9
	
	set_sprite_data( _sprite_data )
	sprite.play()
	sprite.set_material( default_material )
	pass # set_blocktype()
	

# Todo: REMOVE THIS
func set_sprite_data( data : Array ) -> void:
	sprite.animation = data[0]
	sprite.set_frame( data[1] )
	pass # set_sprite_data()
	
	
func score_this_frame() -> void:
	scored_this_frame = true
	pass #score_this_frame()
	
	
func _on_full_fx_tick() -> void:		
	state = PlayerHelper.BLOCKSTATE.FULL_SCORED
	pending_delete = true
	pass #_on_full_fx_tick
	

# Called once when this block is associated in a scored chain
func score() -> void:
	if scored || !is_visible():
		return
		
	sprite.set_material( ScoreShader )

	_sprite_data[0] = "%s_death" % PlayerHelper.ANIM_LOOKUP[Type]
	_sprite_data[1] = 0
	set_sprite_data( _sprite_data )
	sprite.play()
	emit_signal( "BlockScored" )
	land( false )
	scored_this_frame = false

	# spawn fx
	var player = get_parent().get_parent()
	if Type == PlayerHelper.BLOCKTYPES.FULL:
		
		PlayerHelper.spawn_scored_fullblock( get_parent(), 0.33, Vector2( grid_indices[0], grid_indices[1] ) * SIZE )
		var block_grid = get_parent()
		var full_fx = null
		for col in range( block_grid.GridWidth ):
			var fx = ScoreFX.instance()
			fx.color = Type
			player.add_child( fx )
			fx.set_global_position( get_global_position() + Vector2( col * SIZE, 0 ) + ( Vector2( SIZE, SIZE ) * 0.5 ) )
			if !full_fx:
				full_fx = fx
			
		var fx_timer : SceneTreeTimer = get_tree().create_timer( 0.33, true )
		assert( fx_timer.connect( "timeout", self, "_on_full_fx_tick" ) == OK )
		
		set_visible( false )

	else:
		var fx = ScoreFX.instance()
		fx.color = Type
		player.add_child( fx )
		fx.set_global_position( get_global_position() + (Vector2( SIZE, SIZE ) * 0.5 ) )
		
		yield ( fx, "Complete" )
		
		var game_rules = player.get_parent()
		game_rules.on_block_fx_complete( player, fx, self )
				
	pass # score()
	

# Called when this block falls to the floor or hits a block
func land( emit : bool = true ) -> void:
	$block_mover.Landed = true
	if emit:
		var ping = Type == PlayerHelper.BLOCKTYPES.FULL && $block_mover._rows_fallen > 1
		emit_signal( "BlockLanded", ping )
	if $block_mover._rows_fallen > 0:
		get_parent().set_pending_evaluate()
	$block_mover._rows_fallen = 0
	pass # land()
	
	
func set_state( new_state : int) -> void:
	state = new_state
	if state == PlayerHelper.BLOCKSTATE.READY:
		yield ( get_tree().create_timer( 0.33 ), "timeout" )
		
	pass # set_state


func build_name() -> void:
#	var name = sprite.animation + "(" + String( grid_indices[0] ) + "," + String( grid_indices[1] ) + ")"
#	name += ":scored(%s)" % String( scored )
#	name += ":frozen(%s)" % String( mover.Freeze )
#	name += ":landed(%s)" % String( mover.Landed )
	
	var name = sprite.animation + "(%d,%d):scored(%s):frozen(%s):landed(%s)" % [ grid_indices[0], grid_indices[1], scored, mover.Freeze, mover.Landed ]
	set_name( name )
	pass # build_name()
	
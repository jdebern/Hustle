# IMAGE MENU
#
extends Node2D

var child_items : Array = []
var current_index : int = 2

const DURATION : float = 0.5
const QUICK_DURATION : float = 0.2
const SELECTED_SCALE : Vector2 = Vector2(2.0, 2.0)
const NORMAL_SCALE : Vector2 = Vector2(1.0, 1.0)

func _ready():

	for child in get_children():
		if child.get_name() != "Tween":
			child_items.append( child )

	toggle_menu_item( 0 )
	
	pass # _ready()


func toggle_menu_item( index ):
	index = int(clamp(index, 0, child_items.size()-1))

	if index != current_index:
		$Tween.interpolate_property(
			child_items[index],
			'scale',
			null,
			SELECTED_SCALE,
			DURATION,
			Tween.TRANS_CIRC,
			Tween.EASE_IN_OUT)

		$Tween.stop(child_items[current_index], 'scale')
		child_items[current_index].set_scale( NORMAL_SCALE )
		# $Tween.interpolate_property(
		# 	child_items[current_index],
		# 	'scale',
		# 	null,
		# 	NORMAL_SCALE,
		# 	QUICK_DURATION,
		# 	Tween.TRANS_LINEAR,
		# 	Tween.EASE_IN)

	current_index = index
	$Tween.start()

	pass # toggle_menu_item()


func get_menu_action():
	return child_items[current_index].get_name()
	#get_menu_action()


func traverse_list( direction ):
	toggle_menu_item(current_index+direction)
	pass #traverse_list()

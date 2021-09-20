# SCREEN RESIZER
#
extends Node

onready var root = get_tree().get_root()
onready var base_size = Vector2(320, 240)

func _ready():
	get_tree().connect("screen_resized", self, "_on_screen_resized")

	root.set_size_override_stretch(false)
	root.set_size_override(false, Vector2())
	# root.set_as_render_target(true)
	root.set_update_mode(root.UPDATE_ALWAYS)
	root.set_attach_to_screen_rect(root.get_visible_rect())

func _on_screen_resized():
	var new_window_size = OS.get_window_size()
	new_window_size.x = max(new_window_size.x, base_size.x)
	new_window_size.y = max(new_window_size.y, base_size.y)
	OS.set_window_size(new_window_size)

	var scale_w = max(int(new_window_size.x / base_size.x), 1)
	var scale_h = max(int(new_window_size.y / base_size.y), 1)
	var scale = min(scale_w, scale_h)

	var diff = new_window_size - (base_size * scale)
	var diffhalf = (diff * 0.5).floor()

	root.set_size(base_size)
	root.set_attach_to_screen_rect(Rect2(diffhalf, base_size * scale))
	
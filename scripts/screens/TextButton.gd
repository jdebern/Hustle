# TEXT BUTTON
# - Controls pushing text down a few pixels on button press

extends TextureButton

onready var text_node = get_node("text")

export(int) var offset = 1
export(Texture) var text_image = null

func _ready():
	connect("button_down", self, "_on_down")
	connect("button_up", self, "_on_up")

	if text_image:
		get_node("text").texture = text_image

func _on_down():
	text_node.set_position(Vector2(0, offset))

func _on_up():
	text_node.set_position(Vector2(0, 0))

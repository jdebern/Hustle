extends Camera2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_tree().get_root().connect("size_changed", self, "_onResize")
	_onResize()
	pass

func _onResize():
	var defaultX = 320
	var defaultY = 240
	var zoomX = defaultX/get_viewport_rect().size.x
	var zoomY = defaultY/get_viewport_rect().size.y
	set_zoom(Vector2(zoomX, zoomY))

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

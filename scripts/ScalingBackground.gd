extends Polygon2D

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
		var viewportRect = get_viewport_rect()
		var halfWidth = viewportRect.size.x * 0.5
		var halfHeight = viewportRect.size.y * 0.5
		var polyArray = get_polygon()
		polyArray.set(0, Vector2(-halfWidth, halfHeight))
		polyArray.set(1, Vector2(halfWidth, halfHeight))
		polyArray.set(2, Vector2(halfWidth, -halfHeight))
		polyArray.set(3, Vector2(-halfWidth, -halfHeight))
		set_polygon(polyArray)
		global_translate(Vector2(halfWidth, halfHeight))
		for i in range(4):
			print("Index: ", i, "\tx: ", polyArray[i].x, "\ty: ", polyArray[i].y)
		
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

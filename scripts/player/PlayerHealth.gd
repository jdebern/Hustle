extends Object

var color_0 = Color(0.0, 1.0, 0.0)
var color_1 = Color(1.0, 0.0, 0.0)
var percent = 0.0
var _parent_material = null

func init(parent):
	_parent_material = parent.get_material().duplicate()
	parent.set_material(_parent_material)
	pass


func set_percent(p):
	percent = p
	update()
	pass
	
	
func update():
	if _parent_material:
		var interp = color_0.linear_interpolate(color_1, percent)
		_parent_material.set_shader_param("outline_color", interp)
	pass
	
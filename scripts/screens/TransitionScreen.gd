extends Sprite

const MathHelper = preload("res://scripts/helpers/MathHelper.gd")
const EPSILON = 0.16

var _transition_in_timer = Timer.new()
var _transition_out_timer = Timer.new()

export(ShaderMaterial) var TransitionInMaterial = null
export(ShaderMaterial) var TransitionOutMaterial = null
export(float, 0.1, 100.0) var TransitionTime = 1.0 

var shader_threshold = 0

signal TransitionIn
signal TransitionOut


func _ready():
	assert(TransitionInMaterial)
	assert(TransitionOutMaterial)
	_transition_in_timer.set_name("transition_in")
	_transition_in_timer.set_one_shot(true)
	_transition_in_timer.set_wait_time(TransitionTime)
	_transition_in_timer.connect("timeout", self, "_on_transition_in")
	add_child(_transition_in_timer)
	
	_transition_out_timer.set_name("transition_out")
	_transition_out_timer.set_one_shot(true)
	_transition_out_timer.set_wait_time(TransitionTime)
	_transition_out_timer.connect("timeout", self, "_on_transition_out")
	add_child(_transition_out_timer)
	pass
	

func _on_transition_in():
	shader_threshold = 0.0
	get_material().set_shader_param("threshold", shader_threshold)
	emit_signal("TransitionIn")
	pass
	
	
func _on_transition_out():
	shader_threshold = 1.0
	get_material().set_shader_param("threshold", shader_threshold)
	set_visible(false)
	emit_signal("TransitionOut")
	pass
	
	
func transition_in():
	_transition_out_timer.stop()
	_transition_in_timer.start()
	shader_threshold = 1.0
	set_material(TransitionInMaterial)
	get_material().set_shader_param("threshold", shader_threshold)
	set_visible(true)
	pass
	
	
func transition_out():
	_transition_in_timer.stop()
	_transition_out_timer.start()
	shader_threshold = 0.0
	set_material(TransitionOutMaterial)
	get_material().set_shader_param("threshold", shader_threshold)
	pass
	
	
func _process( delta : float ) -> void:
	
	if !_transition_in_timer.is_stopped():
		# transition in
		shader_threshold = 1 - (_transition_in_timer.get_wait_time()-_transition_in_timer.get_time_left() / _transition_in_timer.get_wait_time())
		get_material().set_shader_param("threshold", shader_threshold)
		pass
	if !_transition_out_timer.is_stopped():
		shader_threshold = _transition_out_timer.get_wait_time()-_transition_out_timer.get_time_left() / _transition_out_timer.get_wait_time()
		get_material().set_shader_param("threshold", shader_threshold)
		pass
		
#	if shader_threshold <= EPSILON:
#		shader_threshold = 0
#	elif shader_threshold >= 1.0-EPSILON:
#		shader_threshold = 1.0
	pass
	
	
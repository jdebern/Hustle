# BLOCK INDICATOR
#	- Displays an incoming block in a column
extends Node2D

onready var block = get_node("block")

#Private vars
var _blinkTimer = Timer.new()
var _queueData = null
var _times_visible = 0

const VISIBLE_TIME = 0.40
const INVISIBLE_TIME = 0.10
const VISIBLE_COUNT = 3

func _ready():
	add_child(_blinkTimer)
	get_node("block").mover.Landed = true


func _on_tick():
	_blinkTimer.stop()
	var newTime = INVISIBLE_TIME
	if !is_visible():
		_times_visible += 1
		newTime = VISIBLE_TIME

	_blinkTimer.set_wait_time(newTime)
	_blinkTimer.start()
	set_visible(!is_visible())

	if _times_visible == VISIBLE_COUNT:
		complete()


func set_data(data):
	_queueData = data

	block.set_blocktype(data.blockType, "_alert")

	set_visible(true)
	_blinkTimer.set_wait_time(VISIBLE_TIME)
	_blinkTimer.start()
	_blinkTimer.connect("timeout", self, "_on_tick")


func complete():
	set_visible(false)
	get_parent().indicator_completed(self, _queueData)

func clear():
	_blinkTimer.set_paused(true)
	set_visible(false)
	
# AUTO PLAYER
# Saves and plays game recording events

extends Node

enum ActionType {
	CURSOR_MOVE,
	CURSOR_SWAP
}

class GameAction:
	var player_name = null
	var action_type = CURSOR_MOVE
	var timestamp = 0
	var data = null

var _timestamp = 0
var _record = false
var _playback = false
var _actions = []
var _action_index = 0

func _process(delta):
	if _record || _playback:
		_timestamp += delta
		if _playback:
			_playback()


func start_record():
	_record = true
	# connect to appropriate signals


func start_playback():
	_playback = true
	# load in playback file and fill _actions
	# grab appropriate scenes to manipulate


func _playback():
	for i in range(_action_index, _actions.size()):
		if _actions[i].timestamp < _timestamp:
			_action_index = i
			if _actions[i].action_type == CURSOR_MOVE:
				print(_actions[i].player_name, " cursor moved at ", _timestamp)
			else:
				print(_actions[i].player_name, " cursor swapped at ", _timestamp)

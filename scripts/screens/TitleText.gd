# TITLE TEXT
# Scales the Title

extends Node2D

var locations = []
var characters = []
var scales = [ 3, 3.1, 2.9, 2.8, 3.2, 3 ]
var timescale = 0

func _ready():
	characters.append($H)
	characters.append($U)
	characters.append($S)
	characters.append($T)
	characters.append($L)
	characters.append($E)

	for i in range(characters.size()):
		locations.append(characters[i].get_position())

	timescale = randf() * 100

func _process(delta):
	timescale += delta * 3

	for i in range(characters.size()):
		var dir = 1
		if locations[i].x >= 0:
			dir = -1

		if i % 2 == 0:
			characters[i].set_scale(Vector2(scales[i], scales[i] + sin(timescale * 1)*0.5))
		else:
			characters[i].set_scale(Vector2(scales[i], scales[i] + sin(timescale * 1.5)*0.5))

		characters[i].set_position(Vector2(
			((sin(timescale*0.6) * dir) * 30) * (abs(locations[i].x) / 200)
			, 0) + locations[i])
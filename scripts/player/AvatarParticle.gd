# MULTIPLIER PARTICLE
#	- Zooms to the parent multiplier and adds a count

extends "res://scripts/player/ScoreParticle.gd"

func init():
	set_region_rect(Rect2(color * 8, 0, 8, 8))
	_start_pos = get_global_position()
	_target_pos = get_node("../multiplier").avatar_location

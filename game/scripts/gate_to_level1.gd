extends Node2D

var ready = false

func _on_Area2D_body_entered(body):
	if ready and body.is_in_group("player"):
		PlayerState.last_visited_level = "res://game/levels/level0.tscn"
		_save_level()
		get_tree().change_scene_to_file("res://game/levels/level1.tscn")

func _save_level():
	var level = get_parent()
	level._on_buttons_save_pressed()

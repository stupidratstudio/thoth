extends Node2D

var gate_ready = false
var delay = 0.1

func _process(delta):
	delay -= delta
	if delay < 0:
		gate_ready = true

func _on_Area2D_body_entered(body):
	if gate_ready and body.is_in_group("player"):
		PlayerState.last_visited_level = "res://game/levels/level1.tscn"
		_save_level()
		get_tree().change_scene_to_file("res://game/levels/level0.tscn")

func _save_level():
	var level = get_parent()
	level._on_buttons_save_pressed()

extends Node2D

@export_file("*.tscn") var next_level: String
var gate_ready = false
var delay = 0.1

func _process(delta):
	delay -= delta
	if delay < 0:
		gate_ready = true

func _on_Area2D_body_entered(body):
	if gate_ready and body.is_in_group("player"):
		var level = get_parent().get_parent()
		PlayerState.last_visited_level = level.scene_file_path
		_save_level()
		get_tree().change_scene_to_file(next_level)

func _save_level():
	var level = get_parent().get_parent()
	level._on_buttons_save_pressed()

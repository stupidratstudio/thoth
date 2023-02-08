extends Node2D

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		get_tree().change_scene("res://game/scenes/level0.tscn")
		PlayerState.last_visited_level = "level1"

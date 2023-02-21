extends Node2D

func _ready():
	if PlayerState.last_visited_level == "level1":
		$objects/player.global_position = $gate_from_level1.global_position


func _on_buttons_load_pressed():
	pass # Replace with function body.


func _on_buttons_save_pressed():
	pass # Replace with function body.

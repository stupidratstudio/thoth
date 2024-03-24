extends Control

func _on_new_level0_pressed():
	get_tree().change_scene_to_file("res://test/scenes/level0.tscn")

func _on_new_level1_pressed():
	get_tree().change_scene_to_file("res://test/scenes/level1.tscn")

func _on_new_level2_pressed():
	get_tree().change_scene_to_file("res://test/scenes/level2.tscn")

func _on_load_level0_pressed():
	pass # Replace with function body.

func _on_load_level1_pressed():
	pass # Replace with function body.

func _on_load_level2_pressed():
	pass # Replace with function body.

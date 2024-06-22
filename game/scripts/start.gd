extends Node2D

func _process(delta):
	$Savestate.load_game_state()
	$Savestate.get_game_variables(PlayerState)
	if PlayerState.current_level != "":
		get_tree().change_scene_to_file(PlayerState.current_level)
	else:
		get_tree().change_scene_to_file("res://game/levels/level0.tscn")

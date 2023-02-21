extends Node2D

func _ready():
	if PlayerState.last_visited_level == "level1":
		$objects/player.global_position = $gate_from_level1.global_position


func _on_buttons_load_pressed():
	$Savestate.load_game_state()
	$Savestate.get_game_variables(PlayerState)


func _on_buttons_save_pressed():
	$Savestate.set_game_variables(PlayerState)
	$Savestate.save_game_state()

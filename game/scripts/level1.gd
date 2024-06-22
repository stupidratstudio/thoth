extends Node2D

func _ready():
	return
	$Savestate.load_game_state()
	if $Savestate.visited_level(self):
		$Savestate.unpack_level(self)
		$Savestate.get_game_variables(PlayerState)
	if PlayerState.last_visited_level == "res://game/levels/level0.tscn":
		$objects/player.global_position = $gate_from_level0.global_position

func _on_buttons_load_pressed():
	$Savestate.load_game_state()
	$Savestate.unpack_level(self)
	$Savestate.get_game_variables(PlayerState)

func _on_buttons_save_pressed():
	$Savestate.load_game_state()
	$Savestate.set_game_variables(PlayerState)
	$Savestate.pack_level(self)
	$Savestate.save_game_state()

extends Node2D

var init_load = false
func _process(_delta):
	if init_load:
		return
	init_load = true
	$Savestate.load_game_state()
	if $Savestate.visited_level(self):
		$Savestate.unpack_level(self)
		$Savestate.get_game_variables(PlayerState)

func _on_buttons_load_pressed():
	$Savestate.load_game_state()
	$Savestate.unpack_level(self)
	$Savestate.get_game_variables(PlayerState)

func _on_buttons_save_pressed():
	PlayerState.current_level = scene_file_path
	$Savestate.load_game_state()
	$Savestate.set_game_variables(PlayerState)
	$Savestate.pack_level(self)
	$Savestate.save_game_state()

func get_player():
	return $layers/foreground.get_node("player")

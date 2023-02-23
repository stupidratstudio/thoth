extends Node2D

var serializable_collections = [
	"objects"
]

func _ready():
	$Savestate.load_game_state()
	if $Savestate.visited_level(self):
		$Savestate.unpack_game_state(self)
	if PlayerState.last_visited_level == "res://game/levels/level1.tscn":
		$objects/player.global_position = $gate_from_level1.global_position
	$gate.ready = true

func _on_buttons_load_pressed():
	$Savestate.load_game_state()
	$Savestate.unpack_game_state(self)
	$Savestate.get_game_variables(PlayerState)

func _on_buttons_save_pressed():
	$Savestate.load_game_state()
	$Savestate.set_game_variables(PlayerState)
	$Savestate.pack_game_state(self)
	$Savestate.save_game_state()

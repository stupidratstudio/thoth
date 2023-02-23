extends Node2D

var serializable_collections = [
	"objects"
]

func _ready():
	pass # Replace with function body.

func _on_buttons_load_pressed():
	$Savestate.load_game_state()
	$Savestate.unpack_game_state(self)
	$Savestate.get_game_variables(PlayerState)

func _on_buttons_save_pressed():
	$Savestate.set_game_variables(PlayerState)
	$Savestate.pack_game_state(self)
	$Savestate.save_game_state()

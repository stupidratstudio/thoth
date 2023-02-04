extends Node2D

const serializable_collections = [
	"objects"
]

func _ready():
	randomize()
	$Savegame.set_game_state(self)
	$Savegame.save_game_state()

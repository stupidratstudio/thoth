tool
extends Node
class_name ThothGameState

var save_filename = "savegame.sav"
var game_state = {}

func _enter_tree():
	print(ThothSerializer._serialize_variable(Vector2(1,2)))

func _exit_tree():
	pass

func _get_property_list():
	return [{
		"name": "Savegame",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_CATEGORY
	},
	{
		"name": "save_filename",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT
	}]

func set_game_state(input_node):
	game_state = ThothAssembler._serialize_node(input_node)

func save_game_state():
	print(game_state)

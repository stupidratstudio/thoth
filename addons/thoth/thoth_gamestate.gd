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
	return [
		{
			"name": "Savegame",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_CATEGORY
		},
		{
			"name": "save_filename",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_DEFAULT
		}
	]

func set_game_state(input_node):
	game_state = ThothAssembler._serialize_node(input_node)

func apply_game_state(input_node):
	print("apply:")
	print(game_state)
	print()

func load_game_state():
	var file = File.new()
	file.open("user://" + save_filename, File.READ)
	game_state = parse_json(file.get_line())
	file.close()

func save_game_state():
	var file = File.new()
	file.open("user://" + save_filename, File.WRITE)
	file.store_line(to_json(game_state))
	file.close()

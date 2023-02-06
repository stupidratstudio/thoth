tool
extends Node
class_name ThothGameState

var save_filename = "savegame.sav"
var game_state = {}
var save_data = {}

func _enter_tree():
	pass

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

func save_exists():
	var file = File.new()
	return file.file_exists("user://" + save_filename)

func pack_game_state(input_node):
	game_state = ThothSerializer._serialize_level(input_node)

func unpack_game_state(input_node):
	ThothSerializer._deserialize_level(input_node, game_state)

func load_game_state(game_version = "default"):
	_load_save_data()
	game_state = save_data[game_version]

func save_game_state(game_version = "default"):
	if save_exists():
		_load_save_data()

	save_data[game_version] = game_state
	_save_save_data()

func _load_save_data():
	var file = File.new()
	file.open("user://" + save_filename, File.READ)
	save_data = parse_json(file.get_line())
	file.close()

func _save_save_data():
	var file = File.new()
	file.open("user://" + save_filename, File.WRITE)
	file.store_line(to_json(save_data))
	file.close()

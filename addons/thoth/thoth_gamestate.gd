tool
extends Node
class_name ThothGameState

var save_filename = "savegame.sav"
var game_state = {
	"variables": {},
	"maps": {}
}
var save_data = {}

func _enter_tree():
	pass

func _exit_tree():
	pass

func _get_property_list():
	return [
		{
			"name": "Savestate",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_CATEGORY
		},
		{
			"name": "save_filename",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_DEFAULT
		}
	]

func visited_level(level):
	return game_state.maps.has(level.filename)

func clear_level_history(level_filename):
	game_state.maps.erase(level_filename)

func save_exists():
	var file = File.new()
	return file.file_exists("user://" + save_filename)

func pack_game_state(level):
	game_state.maps[level.filename] = ThothSerializer._serialize_level(level)

func unpack_game_state(level):
	if visited_level(level):
		ThothSerializer._deserialize_level(level, game_state.maps[level.filename])

func set_game_variables(node):
	game_state.variables = ThothSerializer._serialize_object_variables(node)

func get_game_variables(node):
	ThothSerializer._deserialize_object_variables(node, game_state.variables)

func load_game_state(game_version = "default"):
	if save_exists():
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

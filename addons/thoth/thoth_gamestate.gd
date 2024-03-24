@tool
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
	if typeof(level) == TYPE_STRING:
		return game_state.maps.has(level)
	return game_state.maps.has(level.scene_file_path)

func clear_level_history(level_filename):
	game_state.maps.erase(level_filename)

func save_exists():
	return FileAccess.file_exists("user://" + save_filename)

func pack_game_state(level):
	game_state.maps[level.scene_file_path] = ThothSerializer._serialize_level(level)

func unpack_game_state(level):
	if visited_level(level):
		ThothSerializer._deserialize_level(level, game_state.maps[level.scene_file_path])

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
	var file = FileAccess.open("user://" + save_filename, FileAccess.READ)
	var test_json_conv = JSON.new()
	test_json_conv.parse(file.get_line())
	save_data = test_json_conv.get_data()
	file.close()

func _save_save_data():
	var file = FileAccess.open("user://" + save_filename, FileAccess.WRITE)
	file.store_line(JSON.new().stringify(save_data))
	file.close()

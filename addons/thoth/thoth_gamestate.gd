extends Node
class_name ThothGameState

@export var save_filename = "savegame.sav"
var game_state = {
	"globals": {},
	"maps": {}
}
var save_data = {}

func visited_level(level):
	if typeof(level) == TYPE_STRING:
		return game_state.maps.has(level)
	return game_state.maps.has(level.scene_file_path)

func clear_level_history(level_filename):
	game_state.maps.erase(level_filename)

func save_exists():
	return FileAccess.file_exists("user://" + save_filename)

func pack_level(level):
	game_state.maps[level.scene_file_path] = ThothSerializer._serialize_object(level)

func unpack_level(level):
	if visited_level(level):
		ThothDeserializer._deserialize_object(game_state.maps[level.scene_file_path], level)
		ThothDeserializer._deserialize_solve_references(level)

func set_game_variables(node):
	game_state.globals[node.name] = ThothSerializer._serialize_object(node)

func get_game_variables(node):
	if(game_state.globals.has(node.name)):
		ThothDeserializer._deserialize_object(game_state.globals[node.name], node)

func load_game_state(game_version = "default"):
	if save_exists():
		_load_save_data()
		game_state = save_data[game_version]
	else:
		printerr(save_filename + " doesn't exists, couldn't load!")

func save_game_state(game_version = "default"):
	if save_exists():
		_load_save_data()

	save_data[game_version] = game_state
	_save_save_data()

func _load_save_data():
	var file = FileAccess.open("user://" + save_filename, FileAccess.READ)
	var json_conv = JSON.new()
	json_conv.parse(file.get_line())
	save_data = json_conv.get_data()
	file.close()

func _save_save_data():
	var file = FileAccess.open("user://" + save_filename, FileAccess.WRITE)
	file.store_line(JSON.new().stringify(save_data))
	file.close()

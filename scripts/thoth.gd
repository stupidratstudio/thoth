extends Node
class_name Thoth

var hasToLoadMap = false
var loadMapName = ""
var hasToLoadGame = false
var loadGameName = ""
var _refreshing_thread = null
var _refreshing_game = null
var _saving_thread = null
var _saving_game = null
var _saving_filename = null
var _loaded_game_state = null

func _ready():
	_loaded_game_state = _serialize_game(null)
	_saving_thread = Thread.new()
	_refreshing_thread = Thread.new()

func save_exists(filename):
	var file = File.new()
	return file.file_exists("user://" + filename + ".sav")

func set_load_map(map_name):
	hasToLoadMap = true
	loadMapName = map_name

func set_load_game(save_name):
	hasToLoadGame = true
	loadGameName = save_name

func reset_game_state():
	_loaded_game_state = _serialize_game(null)

func refresh_game_state(game, now = false):
	if now:
		_refreshing_game = game
		_refresh_game_state()
		return

	if _refreshing_thread.is_active():
		_refreshing_thread.wait_to_finish()
	_refreshing_game = game
	_refreshing_thread.start(self, "_refresh_game_state", null)

func save_node(game, filename):
	if _saving_thread.is_active():
		_saving_thread.wait_to_finish()
	_saving_game = game
	_saving_filename = filename
	_saving_thread.start(self, "_save_node_function", null)

func _save_node_function(dummy):
	_refreshing_game = _saving_game
	_refresh_game_state()

	var file = File.new()
	file.open("user://" + _saving_filename + ".sav", File.WRITE)
	file.store_line(to_json(_loaded_game_state))
	file.close()

func load_node(game, filename):
	var file = File.new()
	file.open("user://" + filename + ".sav", File.READ)
	_loaded_game_state = parse_json(file.get_line())
	file.close()

	var level = _loaded_game_state.level
	game.load_level(level)

	var player = game.get_player()
	_deserialize_object_data(player, "player", _loaded_game_state.player)

	_create_instances(game, _loaded_game_state.instances[level])

func _create_instances(game, instances):
	var instances_node = game.get_instances()
	for entry in instances:
		var data = instances[entry]
		var object = _deserialize_object_instance(data)
		instances_node.add_child(object)
		_deserialize_object_data(object, entry, data)

	#resolve references
	for entry in instances:
		var data_entries = instances[entry].data
		for variable_name in data_entries:
			if _data_has_reference(data_entries[variable_name]):
				_resolve_reference(game, entry, variable_name, data_entries[variable_name])

func _data_has_reference(data):
	if typeof(data) != TYPE_DICTIONARY:
		return false
	if data.type == "object":
		return true
	if data.type == "array":
		for entry in data.data:
			if _data_has_reference(entry):
				return true
		return false

func _resolve_reference(game, object_name, variable_name, data):
	if typeof(data) != TYPE_DICTIONARY:
		return
	if data.type == "object":
		var object = game.get_object_by_name(object_name)
		object.set(variable_name, game.get_object_by_name(data.name))
	if data.type == "array":
		var object = game.get_object_by_name(object_name)
		var array = []
		for entry in data.data:
			array.push_back(game.get_object_by_name(entry.name))
		object.set(variable_name, array)

#takes the game state into a serialized variable in a thread
func _refresh_game_state():
	var new_data = _serialize_game(_refreshing_game)
	_loaded_game_state.player = new_data.player
	_loaded_game_state.level = new_data.level
	_loaded_game_state.instances[new_data.level] = new_data.instances[new_data.level]

func _serialize(node):
	return null

func _deserialize(input):
	return null

func _serialize_game(game):
	var data = {
		"player" : {},
		"level" : {},
		"instances" : {}
	}

	if not game:
		return data

	var player = game.get_player()
	var level = game.get_level().name

	data.player = _serialize_object(player)
	data.level = level
	data.instances[level] = {}

	for object in game.get_instances().get_children():
		var object_name = object.name
		object_name = object_name.replace("@","")
		data.instances[level][object_name] = _serialize_object(object)

	return data

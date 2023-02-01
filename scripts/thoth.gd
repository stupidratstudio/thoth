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

######################################
## data serialization/deserialization
######################################

func _serialize_variable(variable, object_convert_to_references = false):
	match typeof(variable):
		TYPE_NIL:
			return null
		TYPE_VECTOR2:
			return _serialize_vector2(variable)
		TYPE_VECTOR3:
			return _serialize_vector3(variable)
		TYPE_ARRAY:
			return _serialize_array(variable)
		TYPE_OBJECT:
			if object_convert_to_references:
				return _serialize_object_reference(variable)
			return _serialize_object(variable)

	return variable

func _deserialize_variable(input):
	if typeof(input) != TYPE_DICTIONARY:
		return input

	match input.type:
		"vector2":
			return _deserialize_vector2(input)
		"vector3":
			return _deserialize_vector3(input)
		"array":
			return _deserialize_array(input)
		"object":
			return _deserialize_object(input)
		"object_reference":
			return input

	return null

######################################
## data types serialization
######################################

func _serialize_vector2(input):
	return {
		"type": "vector2",
		"x" : input.x,
		"y" : input.y
	}

func _serialize_vector3(input):
	return {
		"type": "vector3",
		"x" : input.x,
		"y" : input.y,
		"z" : input.z
	}

func _serialize_array(input):
	var array = []
	for entry in input:
		array.push_back(_serialize_variable(entry))
	return {
		"type": "array",
		"data": array
	}

func _serialize_object(input):
	if not is_instance_valid(input):
		return null
	var object_variables = {}
	if input.get("serializable"):
		var variables = input.serializable
		for variable in variables:
			var serialized = _serialize_variable(input.get(variable), true)
			if serialized != null:
				object_variables[variable] = serialized
	return {
		"type" : "object",
		"name": input.name,
		"filename": input.filename,
		"position" : _serialize_variable(input.global_translation),
		"scale" : _serialize_variable(input.scale),
		"rotation": _serialize_variable(input.global_rotation),
		"variables": object_variables
	}

func _serialize_object_reference(input):
	return {
		"type" : "object_reference",
		"name": input.name
	}

######################################
## data types deserialization
######################################

func _deserialize_vector2(input):
	return Vector2(
		input.x,
		input.y
	)

func _deserialize_vector3(input):
	return Vector3(
		input.x,
		input.y,
		input.z
	)

func _deserialize_array(input):
	var array = []
	for entry in input.data:
		array.push_back(_deserialize_variable(entry))
	return array

func _deserialize_object(input):
	var object = load(input.filename).instance()
	object.name = input.name
	object.global_translation = _deserialize_variable(data.position)
	object.scale = _deserialize_variable(data.scale)
	object.global_rotation = _deserialize_variable(data.rotation)
	if object.get("serializable"):
		var variables = object.serializable
		for variable_name in variables:
			var variable_value = input.variables.get(variable)
			if variable_value != null:
				object.set(variable_name, _deserialize_variable(variable_value))
	return object

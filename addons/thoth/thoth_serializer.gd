tool
extends Node
class_name ThothSerializer

const TAG_VARIABLES = "serializable"
const TAG_COLLECTIONS = "serializable_collections"

const TYPE_OBJECT_REFERENCE = "object_reference"

######################################
## data serialization/deserialization
######################################

static func _serialize_variable(variable, object_convert_to_references = false):
	match typeof(variable):
		TYPE_NIL:
			return null
		TYPE_VECTOR2:
			return _serialize_vector2(variable)
		TYPE_VECTOR3:
			return _serialize_vector3(variable)
		TYPE_COLOR:
			return _serialize_color(variable)
		TYPE_BASIS:
			return _serialize_basis(variable)
		TYPE_TRANSFORM:
			return _serialize_transform(variable)
		TYPE_TRANSFORM2D:
			return _serialize_transform2d(variable)
		TYPE_ARRAY:
			return _serialize_array(variable)
		TYPE_OBJECT:
			if object_convert_to_references:
				return _serialize_object_reference(variable)
			return _serialize_object(variable)
	return variable

static func _deserialize_variable(input):
	if typeof(input) == TYPE_NIL:
		return null

	if typeof(input) != TYPE_DICTIONARY:
		return input

	match input.type:
		"vector2":
			return _deserialize_vector2(input)
		"vector3":
			return _deserialize_vector3(input)
		"color":
			return _deserialize_color(input)
		"basis":
			return _deserialize_basis(input)
		"transform":
			return _deserialize_transform(input)
		"transform2d":
			return _deserialize_transform2d(input)
		"array":
			return _deserialize_array(input)
		"object":
			return _deserialize_object(input)
		TYPE_OBJECT_REFERENCE:
			return input

	return null

######################################
## data types serialization
######################################

static func _serialize_vector2(input):
	return {
		"type": "vector2",
		"x" : input.x,
		"y" : input.y
	}

static func _serialize_vector3(input):
	return {
		"type": "vector3",
		"x" : input.x,
		"y" : input.y,
		"z" : input.z
	}

static func _serialize_color(input):
	return {
		"type": "color",
		"r" : input.r,
		"g" : input.g,
		"b" : input.b,
		"a" : input.a
	}

static func _serialize_basis(input):
	return {
		"type": "basis",
		"x": _serialize_variable(input.x),
		"y": _serialize_variable(input.y),
		"z": _serialize_variable(input.z)
	}

static func _serialize_transform(input):
	return {
		"type": "transform",
		"basis": _serialize_variable(input.basis),
		"origin": _serialize_variable(input.origin)
	}

static func _serialize_transform2d(input):
	return {
		"type": "transform2d",
		"x": _serialize_variable(input.x),
		"y": _serialize_variable(input.y),
		"origin": _serialize_variable(input.origin)
	}

static func _serialize_array(input):
	var array = []
	for entry in input:
		array.push_back(_serialize_variable(entry, true))
	return {
		"type": "array",
		"data": array
	}

static func _serialize_object(input):
	if not is_instance_valid(input):
		return null
	var object_variables = _serialize_object_variables(input)
	#object is not serializable
	if object_variables == null:
		return null
	return {
		"type" : "object",
		"name": input.name.replace("@","_"),
		"filename": input.filename,
		"transform" : _serialize_variable(input.global_transform),
		"variables": object_variables
	}

static func _serialize_object_variables(object):
	if object.get(TAG_VARIABLES) != null:
		var object_variables = {}
		var variables = object.get(TAG_VARIABLES)
		for variable in variables:
			var serialized = _serialize_variable(object.get(variable), true)
			object_variables[variable] = serialized
		return object_variables
	return null

static func _serialize_object_reference(input):
	return {
		"type" : TYPE_OBJECT_REFERENCE,
		"name": input.name.replace("@","_")
	}

static func _serialize_collection(input_collection):
	var collection = {}
	for child in input_collection.get_children():
		var object = _serialize_object(child)
		if object != null:
			collection[child.name] = object
	return collection

static func _serialize_level(level):
	var serialized_level = {}
	var level_variables = null
	var collections_data = null
	level_variables = _serialize_object_variables(level)
	if level.get(TAG_COLLECTIONS) != null:
		collections_data = {}
		var collection_names = level.get(TAG_COLLECTIONS)
		for collection_name in collection_names:
			var collection_node = level.get_node(collection_name)
			collections_data[collection_name] = _serialize_collection(collection_node)
	if level_variables != null or collections_data != null:
		return {
			"variables": level_variables,
			"collections": collections_data
		}
	return {}

######################################
## data types deserialization
######################################

static func _deserialize_vector2(input):
	return Vector2(
		input.x,
		input.y
	)

static func _deserialize_vector3(input):
	return Vector3(
		input.x,
		input.y,
		input.z
	)

static func _deserialize_color(input):
	return Color(
		input.r,
		input.g,
		input.b,
		input.a
	)

static func _deserialize_basis(input):
	return Basis(
		_deserialize_variable(input.x),
		_deserialize_variable(input.y),
		_deserialize_variable(input.z)
	)

static func _deserialize_transform(input):
	return Transform(
		_deserialize_variable(input.basis),
		_deserialize_variable(input.origin)
	)

static func _deserialize_transform2d(input):
	return Transform2D(
		_deserialize_variable(input.x),
		_deserialize_variable(input.y),
		_deserialize_variable(input.origin)
	)

static func _deserialize_array(input):
	var array = []
	for entry in input.data:
		array.push_back(_deserialize_variable(entry))
	return array

static func _deserialize_object(input):
	var object = load(input.filename).instance()
	object.name = input.name
	object.global_transform = _deserialize_variable(input.transform)
	_deserialize_object_variables(object, input.variables)
	return object

static func _deserialize_object_variables(object, input_data):
	if object.get(TAG_VARIABLES) != null:
		var variables = object.get(TAG_VARIABLES)
		for variable_name in variables:
			var variable_value = input_data[variable_name]
			object.set(variable_name, _deserialize_variable(variable_value))

static func _deserialize_collection(input_collection, input_state):
	#remove all children
	for child in input_collection.get_children():
		#do this to not mess up references later on
		child.queue_free()
		child.get_parent().remove_child(child)
	for object_name in input_state:
		var object_state = input_state[object_name]
		var object = _deserialize_object(object_state)
		input_collection.add_child(object)
	_reference_solve_collection(input_collection)

static func _deserialize_level(level, input_state):
	_deserialize_object_variables(level, input_state.variables)
	if level.get(TAG_COLLECTIONS) != null:
		var collection_names = level.get(TAG_COLLECTIONS)
		for collection_name in collection_names:
			var collection_node = level.get_node(collection_name)
			var input_state_collection = input_state.collections[collection_name]
			_deserialize_collection(collection_node, input_state_collection)

###############################
##solve references
###############################

static func _reference_solve_collection(input_collection):
	for object in input_collection.get_children():
		if object.get(TAG_VARIABLES) != null:
			if _object_has_references(object):
				_object_solve_references(object, input_collection)

static func _object_solve_references(object, collection):
	var variables = object.get(TAG_VARIABLES)
	for variable_name in variables:
		var variable_value = object.get(variable_name)
		if _variable_is_reference(variable_value):
			var solved_variable = _variable_solve_reference(variable_value, collection)
			object.set(variable_name, solved_variable)

static func _variable_solve_reference(variable_value, collection):
	if typeof(variable_value) == TYPE_DICTIONARY:
		var solved_variable = collection.get_node(variable_value.name)
		return solved_variable
	if typeof(variable_value) == TYPE_ARRAY:
		var array = []
		for entry in variable_value:
			if _variable_is_reference(entry):
				var solved_variable = _variable_solve_reference(entry, collection)
				array.push_back(solved_variable)
			else:
				array.push_back(entry)
		return array
	return null

########################################
##test if contains or is reference
########################################

static func _object_has_references(object):
	var variables = object.get(TAG_VARIABLES)
	for variable_name in variables:
		var variable_value = object.get(variable_name)
		if _variable_is_reference(variable_value):
			return true
	return false

static func _variable_is_reference(input_variable):
	if typeof(input_variable) == TYPE_DICTIONARY:
		return input_variable.type == TYPE_OBJECT_REFERENCE
	if typeof(input_variable) == TYPE_ARRAY:
		for value in input_variable:
			if _variable_is_reference(value):
				return true
	return false

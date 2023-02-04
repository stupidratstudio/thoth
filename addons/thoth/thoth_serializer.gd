tool
extends Node
class_name ThothSerializer

const TAG_VARIABLES = "serializable"

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
	if typeof(input) != TYPE_DICTIONARY:
		return input

	match input.type:
		"vector2":
			return _deserialize_vector2(input)
		"vector3":
			return _deserialize_vector3(input)
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
		"object_reference":
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
		"type": "transform",
		"x": _serialize_variable(input.x),
		"y": _serialize_variable(input.y),
		"origin": _serialize_variable(input.origin)
	}
static func _serialize_array(input):
	var array = []
	for entry in input:
		array.push_back(_serialize_variable(entry))
	return {
		"type": "array",
		"data": array
	}

static func _serialize_object(input):
	if not is_instance_valid(input):
		return null
	var object_variables = {}
	if input.get(TAG_VARIABLES) != null:
		var variables = input.get(TAG_VARIABLES)
		for variable in variables:
			var serialized = _serialize_variable(input.get(variable), true)
			if serialized != null:
				object_variables[variable] = serialized
	else:
		#object is not serializable
		return null
	return {
		"type" : "object",
		"name": input.name,
		"filename": input.filename,
		"transform" : _serialize_variable(input.global_transform),
		"variables": object_variables
	}

static func _serialize_object_reference(input):
	return {
		"type" : "object_reference",
		"name": input.name
	}

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
	if object.get(TAG_VARIABLES) != null:
		var variables = object.get(TAG_VARIABLES)
		for variable_name in variables:
			var variable_value = input.variables.get(variable_name)
			if variable_value != null:
				object.set(variable_name, _deserialize_variable(variable_value))
	return object

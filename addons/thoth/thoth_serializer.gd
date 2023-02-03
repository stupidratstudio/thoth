extends Node

class_name ThothSerializer

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

static func _deserialize_array(input):
	var array = []
	for entry in input.data:
		array.push_back(_deserialize_variable(entry))
	return array

static func _deserialize_object(input):
	var object = load(input.filename).instance()
	object.name = input.name
	object.global_translation = _deserialize_variable(input.position)
	object.scale = _deserialize_variable(input.scale)
	object.global_rotation = _deserialize_variable(input.rotation)
	if object.get("serializable"):
		var variables = object.serializable
		for variable_name in variables:
			var variable_value = input.variables.get(variable_name)
			if variable_value != null:
				object.set(variable_name, _deserialize_variable(variable_value))
	return object

extends Node
class_name ThothSerializer

######################################
## variable serialization
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
		TYPE_TRANSFORM3D:
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

static func _serialize_object(object):
	if not is_instance_valid(object):
		return null

	#find if object is serializable
	var serializable = ThothSerializable._serialize_get_serializable(object)

	if serializable == null:
		return null

	var serialized = {
		"type" : "object",
		"name": _serialize_get_name(object),
	}

	if object is TileMap:
		serialized["core_object"] = true
		serialized["object_type"] = "TileMap"
	elif object.scene_file_path == "":
		serialized["core_object"] = true
		serialized["object_type"] = object.get_class()
	else:
		serialized["scene_file_path"] = object.scene_file_path

	#serialize transformation
	if serializable.transform:
		serialized["transform"] = _serialize_variable(object.transform)

	#serialize object variables
	if len(serializable.variables):
		serialized["variables"] = {}
		for variable in serializable.variables:
			serialized["variables"][variable] = _serialize_variable(object.get(variable), true)

	#serialize children
	if serializable.children:
		serialized["children"] = _serialize_children(object)

	return serialized

static func _serialize_object_reference(object):
	return {
		"type" : "object_reference",
		"name": _serialize_get_path(object)
	}

static func _serialize_children(object):
	var children = {}
	for child in object.get_children():
		if child is ThothSerializable or child is ThothGameState:
			continue
		if ThothSerializable._serialize_get_serializable(child):
			children[_serialize_get_name(child)] = _serialize_object(child)
		else:
			var recurse = _serialize_children(child)
			if recurse == {}:
				continue
			children[_serialize_get_name(child)] = recurse
	return children

static func _serialize_get_name(object):
	return str(object.name).replace("@","_")

static func _serialize_get_path(object):
	return str(object.get_path()).replace("@","_")

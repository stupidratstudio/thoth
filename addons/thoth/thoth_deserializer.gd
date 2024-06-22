extends Node
class_name ThothDeserializer

######################################
## variable deserialization
######################################

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
		"object_reference":
			return input

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
	return Transform3D(
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

static func _deserialize_object(data, object = null):
	#do we update an object or create it?
	if not object:
		if data.has("scene_file_path"):
			object = load(data.scene_file_path).instantiate()
		else:
			if not data.object_type:
				printerr("Something went wrong brufstorg")
			object = ClassDB.instantiate(data.object_type)

	#set the name
	object.name = data.name

	#get the serializable controller
	var serializable = ThothSerializable._serialize_get_serializable(object)

	#set the transform
	if serializable.transform:
		object.transform = _deserialize_variable(data.transform)

	#set the variables
	if len(serializable.variables):
		for variable in serializable.variables:
			if data.variables.has(variable):
				var var_value = _deserialize_variable(data.variables[variable])
				object.set(variable, var_value)

	#set the children
	if serializable.children:
		for child in object.get_children():
			if ThothSerializable._serialize_get_serializable(child):
				if not child.name in data.children:
					child.queue_free()
					child.get_parent().remove_child(child)
		_deserialize_children(data.children, object)

	return object

static func _deserialize_children(data, object, path = ""):
	for child in data:
		#is this a deserializable object?
		if data[child].has("type"):
			var child_name = ThothSerializer._serialize_get_name(data[child])
			var child_object = object.get_node_or_null(path + child_name)
			if child_object:
				_deserialize_object(data[child], child_object)
			else:
				child_object = _deserialize_object(data[child])
				object.add_child(child_object)
		else:
			_deserialize_children(data[child], object, child + "/")

###############################
##solve references
###############################

static func _deserialize_solve_references(object):
	#get the serializable controller
	var serializable = ThothSerializable._serialize_get_serializable(object)

	if serializable:
		if len(serializable.variables):
			for variable in serializable.variables:
				var value = object.get(variable)
				if typeof(value) == TYPE_DICTIONARY or typeof(value) == TYPE_ARRAY:
					object.set(variable, _deserialize_solve_variable_reference(object, value))

	for child in object.get_children():
		_deserialize_solve_references(child)

static func _deserialize_solve_variable_reference(object, data):
	if typeof(data) == TYPE_DICTIONARY:
		if data.type == "object_reference":
			var path = data.name
			return object.get_node_or_null(path)
	if typeof(data) == TYPE_ARRAY:
		var value = []
		for entry in data:
			value.push_back(_deserialize_solve_variable_reference(object, entry))
		return value
	return data
########################################
##test if contains or is reference
########################################

static func _object_has_references(object):
	var serializable = ThothSerializable._serialize_get_serializable(object)
	if not serializable:
		return false

	for variable_name in serializable.variables:
		var variable_value = object.get(variable_name)
		if _variable_is_reference(variable_value):
			return true
	return false

static func _variable_is_reference(input_variable):
	if typeof(input_variable) == TYPE_DICTIONARY:
		return input_variable.type == "object_reference"
	if typeof(input_variable) == TYPE_ARRAY:
		for value in input_variable:
			if _variable_is_reference(value):
				return true
	return false

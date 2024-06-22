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
		object = load(data.scene_file_path).instantiate()

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
			var var_value = _deserialize_variable(data.variables[variable])
			object.set(variable, var_value)

	#set the children
	if serializable.children:
		for child in object.get_children():
			print("eval:", child.name)
			if ThothSerializable._serialize_get_serializable(child):
				print(child.name, "...")
				if not child.name in data.children:
					print("remove ",child.name)
					child.queue_free()
					child.get_parent().remove_child(child)
		_deserialize_children(data.children, object)

	return object

static func _deserialize_children(data, object, path = ""):
	print("dsrl->", object.name)
	for child in data:
		#is this a deserializable object?
		if data[child].has("type"):
			var child_name = ThothSerializer._serialize_get_name(data[child])
			var child_object = object.get_node_or_null(path + child_name)
			print("looking for:", path + child_name)
			if child_object:
				print("found")
				_deserialize_object(data[child], child_object)
			else:
				print("not found")
				child_object = _deserialize_object(data[child])
				object.add_child(child_object)
		else:
			_deserialize_children(data[child], object, child + "/")

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

###############################
##solve references
###############################

static func _reference_solve_collection(input_collection):
	for object in input_collection.get_children():
		if object.get("TAG_VARIABLES") != null:
			if _object_has_references(object):
				_object_solve_references(object, input_collection)

static func _object_solve_references(object, collection):
	var variables = object.get("TAG_VARIABLES")
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
	var variables = object.get("TAG_VARIABLES")
	for variable_name in variables:
		var variable_value = object.get(variable_name)
		if _variable_is_reference(variable_value):
			return true
	return false

static func _variable_is_reference(input_variable):
	if typeof(input_variable) == TYPE_DICTIONARY:
		return input_variable.type == "TYPE_OBJECT_REFERENCE"
	if typeof(input_variable) == TYPE_ARRAY:
		for value in input_variable:
			if _variable_is_reference(value):
				return true
	return false

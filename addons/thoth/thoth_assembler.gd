tool
extends Node
class_name ThothAssembler

const TAG_COLLECTIONS = "serializable_collections"

static func _serialize_node(input_node):
	if input_node.get(TAG_COLLECTIONS) != null:
		var node = {}
		var collection_names = input_node.get(TAG_COLLECTIONS)
		for collection_name in collection_names:
			var collection_node = input_node.get_node(collection_name)
			node[collection_name] = _serialize_collection(collection_node)
		return node
	return {}

static func _serialize_collection(input_collection):
	var collection = {}
	for child in input_collection.get_children():
		var object = ThothSerializer._serialize_object(child)
		if object != null:
			collection[child.name] = object
	return collection

static func _deserialize_node(input_node, input_state):
	if input_node.get(TAG_COLLECTIONS) != null:
		var collection_names = input_node.get(TAG_COLLECTIONS)
		for collection_name in collection_names:
			var collection_node = input_node.get_node(collection_name)
			var input_state_collection = input_state[collection_name]
			_deserialize_collection(collection_node, input_state_collection)

static func _deserialize_collection(input_collection, input_state):
	#remove all children
	for child in input_collection.get_children():
		#do this to not mess up references later on
		child.queue_free()
		child.get_parent().remove_child(child)
	for object_name in input_state:
		var object_state = input_state[object_name]
		var object = ThothSerializer._deserialize_object(object_state)
		input_collection.add_child(object)
	_reference_solve_collection(input_collection)

###############################
##solve references
###############################

static func _reference_solve_collection(input_collection):
	for object in input_collection.get_children():
		if object.get(ThothSerializer.TAG_VARIABLES) != null:
			if _object_has_references(object):
				_object_solve_references(object, input_collection)

########################################
##test is contains or is reference
########################################

static func _object_has_references(object):
	var variables = object.get(ThothSerializer.TAG_VARIABLES)
	for variable_name in variables:
		var variable_value = object.get(variable_name)
		if _variable_is_reference(variable_value):
			return true
	return false

static func _variable_is_reference(input_variable):
	if typeof(input_variable) == TYPE_DICTIONARY:
		return input_variable["type"] == ThothSerializer.TYPE_OBJECT_REFERENCE
	if typeof(input_variable) == TYPE_ARRAY:
		for value in input_variable:
			if _variable_is_reference(value):
				return true
	return false

######################
##solve references
######################

static func _object_solve_references(object, collection):
	var variables = object.get(ThothSerializer.TAG_VARIABLES)
	for variable_name in variables:
		var variable_value = object.get(variable_name)
		if _variable_is_reference(variable_value):
			var solved_variable = _variable_solve_reference(variable_value, collection)
			object.set(variable_name, solved_variable)

static func _variable_solve_reference(variable_value, collection):
	if typeof(variable_value) == TYPE_DICTIONARY:
		var solved_variable = collection.get_node(variable_value["name"])
		return solved_variable
	if typeof(variable_value) == TYPE_ARRAY:
		var array = []
		for entry in array:
			if _variable_is_reference(entry):
				var solved_variable = _variable_solve_reference(entry, collection)
				array.append(solved_variable)
			else:
				array.append(entry)
		return array
	return null

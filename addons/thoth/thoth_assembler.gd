tool
extends Node
class_name ThothAssembler

const TAG_COLLECTIONS = "serializable_collections"

static func _serialize_node(input_node):
	if input_node.get(TAG_COLLECTIONS) != null:
		var node = {}
		var variable_names = input_node.get(TAG_COLLECTIONS)
		for variable_name in variable_names:
			var collection = input_node.get_node(variable_name)
			node[variable_name] = _serialize_collection(collection)
		return node
	return {}

static func _serialize_collection(input_collection):
	var collection = {}
	for child in input_collection.get_children():
		var object = ThothSerializer._serialize_object(child)
		if object != null:
			collection[child.name] = object
	return collection

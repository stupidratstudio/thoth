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
		child.queue_free()
	for object_name in input_state:
		var object_state = input_state[object_name]
		var object = ThothSerializer._deserialize_object(object_state)
		input_collection.add_child(object)

extends Node
class_name ThothSerializable

@export var transform: bool = true
@export var children: bool = true
@export var variables: Array[String] = []

static func _serialize_get_serializable(object):
	#find if object is serializable
	for child in object.get_children():
		if child is ThothSerializable:
			return child
	return null

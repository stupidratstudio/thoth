@tool
extends EditorPlugin

func _enter_tree():
	preload("res://addons/thoth/thoth_serializer.gd")
	preload("res://addons/thoth/thoth_deserializer.gd")
	add_custom_type("Savestate", "Node", preload("thoth_gamestate.gd"), preload("icons/savegame.svg"))
	add_custom_type("Serializable", "Node", preload("thoth_serializable.gd"), preload("icons/savegame.svg"))

func _exit_tree():
	remove_custom_type("Savestate")
	remove_custom_type("Serializable")

tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("Savegame", "Node", preload("thoth_gamestate.gd"), preload("icons/savegame.svg"))

func _exit_tree():
	remove_custom_type("Savegame")

extends Node2D

@export_file("*.tscn") var incoming_level: String

var init_load = false
func _process(_delta):
	if init_load:
		return
	var level = get_parent().get_parent()
	if level.get_player() == null:
		return
	init_load = true
	if PlayerState.last_visited_level == incoming_level:
		level.get_player().global_transform = global_transform

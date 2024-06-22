extends Node2D

var followCursor = false
var followLink = false

var linkToObject = null
@onready var line = $Line2D

func _process(_delta):
	if !is_instance_valid(linkToObject):
		linkToObject = null
	line.set_point_position(0, global_position-position)
	line.set_point_position(1, global_position-position)
	if linkToObject != null:
		line.set_point_position(1, linkToObject.global_position-position)
	if followLink:
		line.set_point_position(1, $Area2DLink.global_position-position)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if followLink:
			$Area2DLink.global_position = event.position
		if followCursor:
			position = event.position
	if event is InputEventMouseButton:
		if !event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			followLink = false
			if !followLink:
				for area in $Area2DLink.get_overlapping_areas():
					var targetObject = area.get_parent()
					if self != targetObject:
						linkToObject = targetObject

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			rotation_degrees += 45/4.0
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			rotation_degrees -= 45/4.0
		if event.button_index == MOUSE_BUTTON_RIGHT:
			queue_free()
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			followCursor = event.pressed
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			followLink = true

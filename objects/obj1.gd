extends Node2D

var followCursor = false

const serializable = []

func _ready():
	pass

func _unhandled_input(event):
	if followCursor:
		if event is InputEventMouseMotion:
			position = event.position

func _on_Area2D_area_entered(area):
	findNewSpot()

func findNewSpot():
	if followCursor:
		return

	var dirX = randi()%10 + 1
	var dirY = randi()%10 + 1

	var d = 32 * scale.x

	var newScale = scale
	newScale.x = dirX/5.0
	newScale.y = dirY/5.0

	$Tween.interpolate_property(self, "scale", scale, newScale, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	$Tween2.interpolate_property(self, "rotation", rotation, deg2rad(45*(randi()%8)), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween2.start()

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_WHEEL_UP:
			$Icon.modulate.r = 0
			$Icon.modulate.g = 0
			$Icon.modulate.b = 0
			while $Icon.modulate.r == 0 and $Icon.modulate.g == 0 and $Icon.modulate.b == 0:
				$Icon.modulate.r = (randi()%3)*0.5
				$Icon.modulate.g = (randi()%3)*0.5
				$Icon.modulate.b = (randi()%3)*0.5
		if event.pressed and event.button_index == BUTTON_WHEEL_DOWN:
			var newScale = randi()%4 + 1
			scale = Vector2.ONE * newScale
		if event.button_index == BUTTON_RIGHT:
			queue_free()
		if event.button_index == BUTTON_MIDDLE:
			followCursor = event.pressed

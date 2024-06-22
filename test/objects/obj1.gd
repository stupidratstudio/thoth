extends Node2D

var followCursor = false
var color = Color(1,1,1): set = _set_color

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

	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", newScale, 1)
	tween.parallel().tween_property(self, "rotation", deg_to_rad(45*(randi()%8)), 1)

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			self.color = Color(0,0,0)
			while color.r == 0 and color.g == 0 and color.b == 0:
				self.color = Color((randi()%3)*0.5,(randi()%3)*0.5,(randi()%3)*0.5)
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var newScale = randi()%4 + 1
			scale = Vector2.ONE * newScale
		if event.button_index == MOUSE_BUTTON_RIGHT:
			queue_free()
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			followCursor = event.pressed

func _set_color(c):
	color = c
	$Icon.modulate.r = c.r
	$Icon.modulate.g = c.g
	$Icon.modulate.b = c.b

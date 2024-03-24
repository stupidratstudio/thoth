extends Node2D

var followCursor = false
var color = Color(1,1,1): set = _set_color

const serializable = [
	"color"
]

func _unhandled_input(event):
	if followCursor:
		if event is InputEventMouseMotion:
			position = event.position

func _on_Area2D_area_entered(area):
	findNewSpot()

func _on_Timer_timeout():
	if position.x < 0 or position.y < 0 or position.x > 1920 or position.y > 1080:
		queue_free()
	if $Area2D.get_overlapping_areas().size() > 0:
		findNewSpot()

func findNewSpot():
	if followCursor:
		return

	var dirX = 0
	var dirY = 0
	while dirX == 0 and dirY == 0:
		dirX = randi()%3
		dirY = randi()%3

	var d = 32 * scale.x

	var newPos = position
	newPos.x = int(newPos.x / d)*d
	newPos.y = int(newPos.y / d)*d

	if dirX == 1:
		newPos.x += d
	if dirX == 2:
		newPos.x -= d
	
	if dirY == 1:
		newPos.y += d
	if dirY == 2:
		newPos.y -= d

	$Tween.stop(self, "position")
	$Tween.interpolate_property(self, "position", position, newPos, 0.1*scale.x, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	$Tween2.interpolate_property(self, "rotation", rotation, deg_to_rad(90*(randi()%4)), 0.3*scale.x, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween2.start()

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

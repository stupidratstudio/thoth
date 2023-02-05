extends Node2D

var followCursor = false
var color = Color(1,1,1) setget _set_color

const serializable = [
	"color"
]

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
			self.color = Color(0,0,0)
			while color.r == 0 and color.g == 0 and color.b == 0:
				self.color = Color((randi()%3)*0.5,(randi()%3)*0.5,(randi()%3)*0.5)
		if event.pressed and event.button_index == BUTTON_WHEEL_DOWN:
			var newScale = randi()%4 + 1
			scale = Vector2.ONE * newScale
		if event.button_index == BUTTON_RIGHT:
			queue_free()
		if event.button_index == BUTTON_MIDDLE:
			followCursor = event.pressed

func _set_color(c):
	color = c
	$Icon.modulate.r = c.r
	$Icon.modulate.g = c.g
	$Icon.modulate.b = c.b

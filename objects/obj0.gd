extends Node2D

var followCursor = false

func _ready():
	#print(filename)
	#print(name)
	pass

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

	var newPos = position
	
	var d = 32

	if dirX == 1:
		newPos.x += d
	if dirX == 2:
		newPos.x -= d
	
	if dirY == 1:
		newPos.y += d
	if dirY == 2:
		newPos.y -= d

	newPos.x = floor(newPos.x / d)*d
	newPos.y = floor(newPos.y / d)*d

	$Tween.stop(self, "position")
	$Tween.interpolate_property(self, "position", position, newPos, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	$Tween2.interpolate_property(self, "rotation", rotation, deg2rad(90*(randi()%4)), 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween2.start()

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 3:
			followCursor = event.pressed

extends Node2D

var followCursor = false
var followLink = false

var linksToObject = []
var lines = []
var nextEmptyLine = 0

func _ready():
	var linksNumber = randi()%5 + 1
	for i in range(0, linksNumber):
		var line = Line2D.new()
		line.width = 10
		line.add_point(Vector2.ZERO)
		line.add_point(Vector2.ZERO)
		line.default_color = _get_color()
		add_child(line)
		lines.push_back(line)
		linksToObject.push_back(null)

func _process(delta):
	for entry in range(0, linksToObject.size()):
		if !is_instance_valid(linksToObject[entry]):
			linksToObject[entry] = null
	for entry in range(0, lines.size()):
		var line = lines[entry]
		var obj = linksToObject[entry]
		line.set_point_position(0, global_position-position)
		line.set_point_position(1, global_position-position)
		if obj != null:
			line.set_point_position(1, obj.global_position-position)
		if followLink and entry == nextEmptyLine:
			line.set_point_position(1, $Area2DLink.global_position-position)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if followLink:
			$Area2DLink.global_position = event.position
		if followCursor:
			position = event.position
	if event is InputEventMouseButton:
		if !event.pressed and event.button_index == BUTTON_LEFT:
			followLink = false
			if !followLink:
				for area in $Area2DLink.get_overlapping_areas():
					linksToObject[nextEmptyLine] = area.get_parent()

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
		if event.pressed and event.button_index == BUTTON_LEFT:
			followLink = true
			nextEmptyLine = -1
			for entry in range(0, linksToObject.size()):
				if linksToObject[entry] == null:
					nextEmptyLine = entry
			if nextEmptyLine == -1:
				nextEmptyLine = randi() % lines.size()

func _get_color():
	return Color(randi()%2, randi()%2, randi()%2)

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

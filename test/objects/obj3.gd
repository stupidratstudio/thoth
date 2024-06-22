extends Node2D

var followCursor = false
var followLink = false

var linksToObject = []
var nextEmptyLine = 0
var color = Color(1,1,1): set = _set_color

func _ready():
	if linksToObject.size() == 0:
		var newLen = 6# randi()%5 + 1
		for i in range(0, newLen):
			linksToObject.push_back(null)

func _process(delta):
	for entry in range(0, linksToObject.size()):
		if !is_instance_valid(linksToObject[entry]):
			linksToObject[entry] = null
	if linksToObject.size() != $lines.get_child_count():
		_set_lines_number(linksToObject.size())
	for entry in range(0, linksToObject.size()):
		var line = $lines.get_child(entry)
		var obj = linksToObject[entry]
		line.set_point_position(0, global_position-position)
		line.set_point_position(1, global_position-position)
		if obj != null:
			line.set_point_position(1, obj.global_position-position)
		if followLink and entry == nextEmptyLine:
			line.set_point_position(1, $Area2DLink.global_position-position)

func _set_lines_number(number):
	for line in $lines.get_children():
		line.queue_free()
	for i in range(0, number):
		var line = Line2D.new()
		line.width = 10
		line.add_point(Vector2.ZERO)
		line.add_point(Vector2.ZERO)
		line.default_color = _get_line_color()
		$lines.add_child(line)

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
						linksToObject[nextEmptyLine] = targetObject

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
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			followLink = true
			nextEmptyLine = -1
			for entry in range(0, linksToObject.size()):
				if linksToObject[entry] == null:
					nextEmptyLine = entry
			if nextEmptyLine == -1:
				nextEmptyLine = randi() % $lines.get_child_count()

func _get_line_color():
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

	var tween: Tween = create_tween()
	tween.tween_property(self, "position", newPos, 1)

func _set_color(c):
	color = c
	$Icon.modulate.r = c.r
	$Icon.modulate.g = c.g
	$Icon.modulate.b = c.b

extends Node2D

onready var obj0 = preload("res://objects/obj0.tscn")

var toAdd = 0

func _ready():
	randomize()
	for i in range(0,10):
		addNewObj(obj0)

func _process(_delta):
	if randi() % 2 == 0:
		if toAdd:
			toAdd -= 1
			addNewObj(obj0)

func addNewObj(object, newPosition = null):
	var o = object.instance()
	o.position = Vector2(floor(randf()*15), floor(randf()*10))*64
	if newPosition != null:
		o.position = newPosition
	$objects.add_child(o)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		$Area2D.position = event.position
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == 1:
			if $Area2D.get_overlapping_areas().size() == 0:
				addNewObj(obj0, $Area2D.position)
				get_tree().set_input_as_handled()

extends Node2D

onready var obj0 = preload("res://objects/obj0.tscn")
onready var obj1 = preload("res://objects/obj1.tscn")
onready var obj2 = preload("res://objects/obj2.tscn")
onready var obj3 = preload("res://objects/obj3.tscn")

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
	if event is InputEventKey:
		if $Area2D.get_overlapping_areas().size() == 0:
			if event.pressed and event.scancode == KEY_1:
				addNewObj(obj0, $Area2D.position)
			if event.pressed and event.scancode == KEY_2:
				addNewObj(obj1, $Area2D.position)
			if event.pressed and event.scancode == KEY_3:
				addNewObj(obj2, $Area2D.position)
			if event.pressed and event.scancode == KEY_4:
				addNewObj(obj3, $Area2D.position)
	if event is InputEventMouseMotion:
		$Area2D.position = event.position

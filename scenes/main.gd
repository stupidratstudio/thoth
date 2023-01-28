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
	o.global_transform.origin = Vector2(floor(randf()*15), floor(randf()*10))*64
	if newPosition != null:
		o.global_transform.origin = newPosition
	add_child(o)

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == 1:
			$Area2DMouse.monitoring = true
			$Area2DMouse.position = event.position
			if $Area2DMouse.get_overlapping_areas().size() <= 1:
				var pos = event.position
				pos.x = floor(pos.x/64)*64
				pos.y = floor(pos.y/64)*64
				addNewObj(obj0, pos)

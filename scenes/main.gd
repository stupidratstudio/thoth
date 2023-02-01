extends Node2D

const TestClass = preload("res://scripts/thoth_gamestate.gd")

func _ready():
	randomize()
	var test = TestClass.new()

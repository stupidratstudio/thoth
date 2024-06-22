extends Control

var value = 5: set = set_value

func _ready():
	_display()

func set_value(v):
	value = v
	_display()

func _display():
	$Display.text = str(value)

func _on_Down_pressed():
	value -= 1
	_display()

func _on_Up_pressed():
	value += 1
	_display()

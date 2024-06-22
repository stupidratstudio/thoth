extends Node2D

var a = 1
var b = 1
var c = 1

func _ready():
	randomize()
	$a.value = a
	$b.value = b
	$c.value = c

func _on_config_load_pressed():
	$ConfigState.load_game_state()
	$ConfigState.get_game_variables(self)
	$a.value = a
	$b.value = b
	$c.value = c

func _on_config_save_pressed():
	a = $a.value
	b = $b.value
	c = $c.value
	$ConfigState.load_game_state()
	$ConfigState.set_game_variables(self)
	$ConfigState.save_game_state()

extends Node2D

var a = 1
var b = 1
var c = 1

func _ready():
	_run_test()
	return

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

func _run_test():
	var dictionar = {"x":"34","nb":{"a":3.4,"b":false}, "af":[24,5,23],"cio":true}
	var serialized = ThothSerializer._serialize_dictionary(dictionar)
	var deserialized = ThothDeserializer._deserialize_dictionary(serialized)
	print(dictionar)
	print(serialized)
	print(deserialized)
	print(dictionar == deserialized)

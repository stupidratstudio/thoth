extends Node2D

var a = 5;
var b = 1;
var c = 2;
var d = 8;

const serializable = [
	"a",
	"b",
	"c",
	"d"
]

func _ready():
	$a.value = a
	$b.value = b
	$c.value = c
	$d.value = d

func _on_buttons_load_pressed():
	$Savestate.load_game_state()
	$Savestate.unpack_game_state(self)
	$a.value = a
	$b.value = b
	$c.value = c
	$d.value = d

func _on_buttons_save_pressed():
	a = $a.value
	b = $b.value
	c = $c.value
	d = $d.value
	$Savestate.load_game_state()
	$Savestate.pack_game_state(self)
	$Savestate.save_game_state()

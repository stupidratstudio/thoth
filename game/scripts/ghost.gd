extends CharacterBody2D

var serializable = []

var coin = preload("res://game/objects/coin.tscn")

var walkDirection = Vector2.ZERO
var speed = 100
var speedBoost = 0
var life = 3

func _ready():
	_on_Timer_timeout()

func _process(delta):
	if speedBoost > 0:
		speedBoost -= delta * 30
		if speedBoost < 0:
			speedBoost = 0

func _physics_process(delta):
	self.set_velocity(walkDirection * (speed+speedBoost))
	self.move_and_slide()
	self.velocity

func _on_Timer_timeout():
	walkDirection.x = (randi()%3) - 1
	walkDirection.y = (randi()%3) - 1
	$Timer.start()

func hit():
	life -= 1
	if life == 0:
		var new_coin = coin.instantiate()
		new_coin.position = position
		get_parent().add_child(new_coin)
		queue_free()
	speedBoost = 250
	_on_Timer_timeout()

extends CharacterBody2D

var walkDirection = Vector2.ZERO
var lastWalkDirection = Vector2.ZERO
var speed = 300

func _ready():
	pass # Replace with function body.

func _process(delta):
	_setCoins()
	walkDirection = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		walkDirection+=Vector2(0,-1)
		lastWalkDirection = walkDirection
	if Input.is_action_pressed("move_down"):
		walkDirection+=Vector2(0,1)
		lastWalkDirection = walkDirection
	if Input.is_action_pressed("move_left"):
		walkDirection+=Vector2(-1,0)
		lastWalkDirection = walkDirection
	if Input.is_action_pressed("move_right"):
		walkDirection+=Vector2(1,0)
		lastWalkDirection = walkDirection
	$wand.rotation = lastWalkDirection.angle() + PI/2
	$wand.visible = false
	if Input.is_action_pressed("move_action"):
		$wand.visible = true
	if Input.is_action_just_pressed("move_action"):
		var objects = $wand/Area2D.get_overlapping_bodies()
		for object in objects:
			if object.is_in_group("ghost"):
				object.hit()
				

func _physics_process(delta):
	self.set_velocity(walkDirection * speed)
	self.move_and_slide()
	self.velocity

func _setCoins():
	get_parent().get_parent().get_parent().get_node("coin_display").set_coin(PlayerState.collected_coins)

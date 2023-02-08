extends KinematicBody2D

var coin = 0

var walkDirection = Vector2.ZERO
var speed = 300

func _ready():
	pass # Replace with function body.

func _process(delta):
	walkDirection = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		walkDirection+=Vector2(0,-1)
	if Input.is_action_pressed("move_down"):
		walkDirection+=Vector2(0,1)
	if Input.is_action_pressed("move_left"):
		walkDirection+=Vector2(-1,0)
	if Input.is_action_pressed("move_right"):
		walkDirection+=Vector2(1,0)

func _physics_process(delta):
	self.move_and_slide(walkDirection * speed)

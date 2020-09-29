extends "res://Character/states/states.gd"

const UP = Vector3(0,-1,0)
export var acceleration = 100
export(int) var sprintSpeed = 30
export(int) var speed = 20
var angleDifference: float
onready var animTree = get_parent().get_parent().get_node("AnimationTree")
onready var animState = animTree.get("parameters/playback")
onready var character = get_parent().get_parent().get_node("characterNodes")
onready var floorGang = get_parent().get_parent().get_node("characterNodes/RayCastFloor")

var velocity = Vector3()

var GRAVITY
export(float) var timeToJumpApex = .7
export(float) var jumpHeight = 1

func handle_input(event):
	#top Level input can got here
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	GRAVITY = -(2 * jumpHeight)/ pow(timeToJumpApex,2)

func get_input_direction():
	var direction = Vector3()
	var uniDir = Vector3()

	var tracker = get_parent().get_parent().get_node("cameraRig/tracker")
	
	direction.x = Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up")
	direction.z = Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left")
	direction = direction.normalized()
	
	if Input.is_action_pressed("ui_up"):
		uniDir += tracker.transform.basis.z 
	elif Input.is_action_pressed("ui_down"):
		uniDir -= tracker.transform.basis.z 
	if Input.is_action_pressed("ui_left"):
		uniDir += tracker.transform.basis.x
	elif Input.is_action_pressed("ui_right"):
		uniDir -= tracker.transform.basis.x
		
	uniDir = uniDir.normalized()*(clamp((abs(direction.z)+abs(direction.x)),0,1))
	
	return(uniDir)

func _rotatePlayer(direction):
	var angle = atan2(direction.x, direction.z)
	var characterRotation = character.get_rotation()
	angleDifference = angle - characterRotation.y
	if direction != Vector3.ZERO:
		character.rotate_y(angleDifference)
	
func _move(speed, direction, delta):
	velocity.x = move_toward(velocity.x, direction.x*speed, acceleration*delta) 
	velocity.z = move_toward(velocity.z, direction.z*speed, acceleration*delta) 
	velocity = owner.move_and_slide(velocity, UP)
	
func _gravity():
	velocity.y += GRAVITY

func putSwordInTimer():
	yield(get_tree().create_timer(5), "timeout")
	swordsInForTheBoys()

func swordsInForTheBoys():
	animTree.set("parameters/idlerun/idleAttack/blend_amount", 0.00)
	animTree.set("parameters/idlerun/runAttack/blend_amount", 0.00)
	animTree.set("parameters/jump/jumpAttack/blend_amount", 0.00)

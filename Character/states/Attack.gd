extends "res://Character/states/states.gd"

onready var animTree = get_parent().get_parent().get_node("AnimationTree")
onready var animState = animTree.get("parameters/playback")
onready var character = get_parent().get_parent().get_node("characterNodes")
var direction: Vector3
var characterRotation: Vector3
var angleDifference: float
var velocity: Vector3
var acceleration = 50
var speed = 5
var UP = Vector3(0,1,0)
var currentAnimation
var chargReady
var attackEnding = true

var attackCombo: int

signal attacking

func enter():
	animState.travel("powerSword")
	attackCombo = 0
	attackEnding = true
	
func onAttackEnd():
	
	if attackEnding:
		attackCombo = 0
		chargReady = false
		emit_signal("finished", "previous")
		swordsOutForTheBoys()
		attackEnding = false
	else:
		attackCombo = 0
		chargReady = false
		swordsOutForTheBoys()
		
	
func update(delta):
	
	currentAnimation =	animState.get_current_node()
	
	if chargReady:
		animState.travel("SwordHold")
		attackCombo = -1
		var inputDirection = get_input_direction()
		move(speed,inputDirection,delta)
		rotatePlayer(inputDirection)
		
		if Input.is_action_just_released("attack"):
			chargReady = false
			
	if Input.is_action_just_released("attack") && attackCombo == -1:
		animState.travel("smashEnd")
	elif Input.is_action_just_released("attack") && attackCombo == 0:
		attackCombo = attackCombo+1
		animState.travel("attack1")
	elif Input.is_action_just_released("attack") && attackCombo == 1:
		animState.travel("attack2")
		attackCombo = attackCombo+1
	elif Input.is_action_just_released("attack") && attackCombo == 2:
		animState.travel("attack3")
		attackCombo = 0
	elif Input.is_action_pressed("attack") && attackCombo == 0:
		animState.travel("powerSword")


	emit_signal("attacking")
	
func onChargedAttack():
	chargReady = true
	

func swordsOutForTheBoys():
	animTree.set("parameters/idlerun/idleAttack/blend_amount", 1.00)
	animTree.set("parameters/idlerun/runAttack/blend_amount", 1.00)
	animTree.set("parameters/jump/jumpAttack/blend_amount", 1.00)
	
func get_input_direction():
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

func rotatePlayer(dir):
	var angle = atan2(dir.x, dir.z)
	characterRotation = character.get_rotation()
	angleDifference = angle - characterRotation.y
	if direction != Vector3.ZERO:
		character.rotate_y(angleDifference)
		
func move(speed, dir, delta):
	velocity.x = move_toward(velocity.x, dir.x*speed, acceleration*delta) 
	velocity.z = move_toward(velocity.z, dir.z*speed, acceleration*delta) 
	velocity = owner.move_and_slide(velocity, UP)

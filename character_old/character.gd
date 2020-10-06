extends KinematicBody

##Character Controller Settings
export var SprintOn: bool
export var DodgeOn: bool
export var JumpOn: bool
export var FreeCam: bool
export var attackOn: bool
export var blockOn: bool

##Movement variables
export var speed = 20
export var sprintSpeed = 30
export var dodgeSpeed = 50
var direction = Vector3.ZERO
var dodgeDirection = Vector3()
var angleDifference: float
var turnVelocity: float
var velocity = Vector3.ZERO
export var acceleration = 100
export var sprintAccelerationg = 50
var uniDir = Vector3.ZERO
onready var camera = get_node("cameraRig/tracker/Camera").get_global_transform()
onready var rig = $cameraRig
onready var tracker = get_node("cameraRig/tracker")

## Attack Variables
onready var attackComboTimer = $characterNodes/attackComboTimer
var attackCount = 0
var combo = false
var attackAnimations = ["attack1","attack2","attack3"]

##Gravity related variables##
var GRAVITY
var jumpVelocity
export(float) var timeToJumpApex = 1.1
export(float) var jumpHeight = 1
const UP = Vector3(0,-1,0)
onready var floorGang = $characterNodes/RayCastFloor

##Animation stuff
onready var animPlayer = $characterNodes/Chibi/AnimationPlayer
onready var animTree = $AnimationTree
onready var animStates = animTree.get("parameters/playback")
onready var animIdleBlend = animTree.get("parameters/idlerun/idleBlend/blend_amount")
onready var character = $characterNodes
onready var target = $characterNodes/chaser
var currentAnimation
var targetVector = Vector3()
var turnSpead = 100
var blendamount: float

#signal stuff
signal currentState
signal currentDirection
signal freeCamOn

##STATES'nShit

enum{
	MOVE,
	SPRINT,
	JUMP,
	DODGE,
	ATTACK,
	BLOCK
}

var state = MOVE

# Called when the node enters the scene tree for the first time.
func _ready():
	emit_signal("freeCamOn", FreeCam)
	GRAVITY = -(2 * jumpHeight)/ pow(timeToJumpApex,2)
	jumpVelocity = abs(GRAVITY) * timeToJumpApex

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	gravity()
	inputController()
	
	match state:
		MOVE:
			moveState(delta)
			emit_signal("currentState",state)
		JUMP:
			jumpState()
			emit_signal("currentState",state)
		SPRINT:
			sprintState(delta)
			emit_signal("currentState",state)
		DODGE:
			dodgeState(delta)
			emit_signal("currentState",state)
		ATTACK:
			attackState(delta)
			emit_signal("currentState", state)
		BLOCK:
			blockState(delta)
			emit_signal("currentState", state)
	animations()
	velocity = move_and_slide(velocity, UP)
	
func animations():
	currentAnimation =	animStates.get_current_node()
	
	match state:
		MOVE:
			rotatePlayer()
			animStates.travel("idlerun")
			setBlendProperty()
			animTree.set("parameters/idlerun/idleBlend/blend_amount", blendamount)
			animTree.set("parameters/idlerun/sprintBlend/blend_amount", 0.00)
		JUMP:
			animStates.travel("jump")
		SPRINT:
			rotatePlayer()
			animStates.travel("idlerun")
			setBlendProperty()
			animTree.set("parameters/idlerun/sprintBlend/blend_amount", blendamount)
		DODGE:
			animStates.travel("dodge")
		ATTACK:
			if attackCount < 3:
				animStates.travel(attackAnimations[attackCount])
		BLOCK:
			rotatePlayer()
			animStates.travel("block")

func rotatePlayer():
	
	var angle = atan2(uniDir.x, uniDir.z)
	var charRot = character.get_rotation()
	angleDifference = angle - charRot.y

	if uniDir != Vector3.ZERO:	
		character.rotate_y(angleDifference)


func setBlendProperty():
	if state == MOVE:
		blendamount = velocity.length()/speed
		if blendamount <= .1:
			blendamount = 0
	elif state == SPRINT:
		blendamount = velocity.length()/sprintSpeed
		if blendamount <= .1:
			blendamount = 0
##TODO Seperate these cunts so that sprint has a proper blend curve

func inputController():
	direction.x = Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up")
	direction.z = Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left")
	direction = direction.normalized()
	
	if Input.is_action_pressed("ui_up"):
		uniDir += tracker.transform.basis.z 
		dodgeDirection += tracker.transform.basis.z 
	elif Input.is_action_pressed("ui_down"):
		uniDir -= tracker.transform.basis.z 
		dodgeDirection-= tracker.transform.basis.z 
	if Input.is_action_pressed("ui_left"):
		uniDir += tracker.transform.basis.x
		dodgeDirection += tracker.transform.basis.x
	elif Input.is_action_pressed("ui_right"):
		uniDir -= tracker.transform.basis.x
		dodgeDirection -= tracker.transform.basis.x
	
	dodgeDirection = dodgeDirection.normalized()
	uniDir = uniDir.normalized()*(clamp((abs(direction.z)+abs(direction.x)),0,1))

	emit_signal("currentDirection", uniDir) #feeds signal to the camera target so it can know where to look to
	
	##mate.... Make a real state machine already...
	if (Input.is_action_just_pressed("block") && (state != JUMP && state != DODGE)) && blockOn:
		state = BLOCK
	elif (Input.is_action_just_pressed("attack") && (state != JUMP && state != DODGE)) && attackOn:
		state = ATTACK
	elif ((Input.is_action_just_pressed("ui_accept") && floorGang.is_colliding()) && JumpOn) && (state !=ATTACK && state !=DODGE && state!=BLOCK):
		state = JUMP
	elif (Input.is_action_just_pressed("dodge") && (state!=JUMP && state !=ATTACK && state!=BLOCK)) && DodgeOn:
		state = DODGE
	elif (Input.is_action_pressed("sprintKey") && (state!=JUMP && state !=ATTACK && state !=DODGE && state!=BLOCK)) && SprintOn:
		state = SPRINT
	elif floorGang.is_colliding() && (state!=DODGE && state !=ATTACK && state!=BLOCK):
		state = MOVE

	if Input.is_action_just_released("block"):
		state = MOVE
		
func moveState(delta):
	velocity.x = move_toward(velocity.x, uniDir.x*speed, acceleration*delta) 
	velocity.z = move_toward(velocity.z, uniDir.z*speed, acceleration*delta) 

func sprintState(delta):
	velocity.x = move_toward(velocity.x, uniDir.x*sprintSpeed, sprintAccelerationg*delta) 
	velocity.z = move_toward(velocity.z, uniDir.z*sprintSpeed, sprintAccelerationg*delta) 

func jumpState():
	if floorGang.is_colliding():
		velocity.y = jumpVelocity*35
	else:
		gravity()

func dodgeState(delta):
	velocity.x = move_toward(velocity.x, dodgeDirection.x*dodgeSpeed, sprintAccelerationg*delta) 
	velocity.z = move_toward(velocity.z, dodgeDirection.z*dodgeSpeed, sprintAccelerationg*delta) 

func attackState(delta):
	stopMoving(delta)

	if Input.is_action_pressed("attack"):
		print(attackCount)
		combo = true
		if currentAnimation == "attack1":
			attackCount = 1
		elif currentAnimation == "attack2":
			attackCount = 2
		elif currentAnimation == "attack3":
			attackCount = 0
	else:
		combo = false
		attackCount = 0
	
func blockState(delta):
	stopMoving(delta)

func gravity():
#	if (rayCastLeft.is_colliding() || rayCastRight.is_colliding()): #walljumpgrabity
#		if velocity.y < 0 && (rayCastLedgeLeft.is_colliding() || rayCastLedgeRight.is_colliding()):
#			velocity.y = 0
#		else:
#			velocity.y += GRAVITY*.2
#			velocity.y = clamp(velocity.y,-300,30)
#	elif state == WALLHOLD:
#		pass
#	else:
	velocity.y += GRAVITY

func stopMoving(delta):
	velocity.x = move_toward(velocity.x, 0.00, sprintAccelerationg*delta)
	velocity.z = move_toward(velocity.z, 0.00, sprintAccelerationg*delta) 


func dodgeEnd():
	state = MOVE

func onAttackEnd():
	if combo:
		pass
	else:
		combo = false
		state = MOVE
		

func attackComboReset():
	attackCount = 0
	combo = false



func _on_attackComboTimer_timeout():
	print("attack Time out")
	attackCount = 0

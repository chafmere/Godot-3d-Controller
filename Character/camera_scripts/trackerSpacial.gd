extends Spatial

signal cameraControl

onready var cameraTween = $cameraTween
export(NodePath) var chaserPath
export(NodePath) var topLevelNode
var character
var chaser
#onready var chaser = get_parent().get_parent().get_node("characterNodes/chaser")
onready var tracker = $"."

var chaserPosition = Vector3()
var characterPosition = Vector3()
var cameraPos = Vector3()
var chaserPositionGround = Vector3()
var targetPosition = chaserPosition
var cameraSpeed

##Mouse Control
var rotX = 0
var rotY = 0
var cameraMouseSensitivity = .001
var mouseSensitivity = cameraMouseSensitivity * 40
export(bool) var cameraControl

##JoyStick Control
var joyAxis: Vector3
var joyPressure: Vector3
var joyAxisVelocity: Vector3
var joySensitivity = .03
var tryJoyStick: bool
var trackerRotation
var automaticFollow: bool
var automaticTarget: bool
onready var cameraTimer = $Timer
var distance = 5
var rotationVelocity = Vector3()
var currentEnemy

#targeting control
var mainTarget
var enemies: Array
var currentTarget = 0
var targetLocation:Vector3
var characterLocation:Vector3
var cameraLocation
export(NodePath) var noEnemyTarget
onready var noEnemyTar = get_node(noEnemyTarget)
var targetIcon
var UP = Vector3(0,1,0)
var totaltargets: int



func _ready():
	set_as_toplevel(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	emit_signal("cameraControl",cameraControl)
	cameraSpeed = .1
	chaser = get_node(chaserPath)
	character = get_node(topLevelNode)
	automaticFollow = false
	automaticTarget = false
	
func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if cameraControl && !automaticTarget: 
		if event is InputEventMouseMotion && automaticTarget == false:
			mouseCameraLook(event)
			tryJoyStick = false
			automaticFollow = false
			
	if Input.is_action_just_pressed("target") && enemies.empty():
		automaticFollow = true
	
	if Input.is_action_just_pressed("target") && !enemies.empty():
		automaticFollow = false
		automaticTarget = true

		
	if Input.is_action_just_released("target") && !enemies.empty():
		automaticTarget = false
		if targetIcon == null:
			pass
		else:
			targetIcon.queue_free()

func _process(delta):
	chaserPosition = chaser.get_global_transform().origin
	characterPosition = character.get_global_transform().origin
	cameraPos = get_global_transform().origin
	trackerRotation = tracker.get_rotation()
	
	chaserPositionGround = Vector3(chaserPosition.x, cameraPos.y , chaserPosition.z)
		
	if cameraControl:
		
		if !automaticTarget:
			joyAxis.y = Input.get_action_strength("rightStickUp")-Input.get_action_strength("rightStickDown")
			joyAxis.x = Input.get_action_strength("rightStickRight")-Input.get_action_strength("rightStickLeft")
			joyAxis = joyAxis.normalized()
			
			if joyAxis != Vector3.ZERO:
				tryJoyStick = true
				automaticFollow = false
			
		if tryJoyStick:
			setJoyStickVelocity(delta)

		
		if automaticTarget:
				focusTarget(delta)
				if Input.is_action_just_pressed("rightStickRight") || Input.is_action_just_pressed("rightStickLeft"):
					nextTarget() 
			#AutoCameraLook(AutoAxisVelocity)
			#reset other controllers to match this new rotaion
				rotY = 0 #assumption: AutoCameraLook() holds x and z at 0.00
				joyPressure.y = 0
				joyAxisVelocity.y = 0
				rotX = -trackerRotation.y
				joyPressure.x = -trackerRotation.y
				joyAxisVelocity.x = -trackerRotation.y
			
		if automaticFollow:
			followPlayer()
			rotY = 0 #assumption: AutoCameraLook() holds x and z at 0.00
			joyPressure.y = 0
			joyAxisVelocity.y = 0
			rotX = -trackerRotation.y
			joyPressure.x = -trackerRotation.y
			joyAxisVelocity.x = -trackerRotation.y

		
	cameraTween.interpolate_property(tracker,"translation", cameraPos, targetPosition, cameraSpeed,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	cameraTween.start()
	
func followPlayer():
	targetLocation = noEnemyTar.get_global_transform().origin
	look_at(targetLocation, Vector3(0,1,0))


func focusTarget(delta):

	if targetIcon == null:
		var TargetIcon = load("res://enemy/TargetIndicator.tscn")
		targetIcon = TargetIcon.instance()
		var world = get_tree().current_scene
		world.add_child(targetIcon)

	cameraLocation = tracker.get_global_transform().origin
	if enemies.empty():
		automaticTarget = false
		if targetIcon != null:
			targetIcon.queue_free()
	else:
		mainTarget = enemies[currentTarget]
		targetLocation = mainTarget.get_global_transform().origin
		targetIcon.look_at(cameraLocation, UP)
		targetLocation.y = clamp(joyPressure.y,-.6,.8)
		rotationVelocity = lerp(rotationVelocity, targetLocation, 2*delta)
		targetIcon.global_transform = mainTarget.get_global_transform()
			
		look_at(rotationVelocity, Vector3(0,1,0))
		rotate_object_local(Vector3(0,1,0),3.14)

func nextTarget():
	totaltargets = enemies.size()-1
	
	if currentTarget >= totaltargets || currentTarget <= -totaltargets:
		currentTarget = 0
	elif Input.is_action_just_pressed("rightStickRight"):
		currentTarget = currentTarget+1
	elif Input.is_action_just_pressed("rightStickLeft"):
		currentTarget = currentTarget-1
	else:
		currentTarget = currentTarget+1

func mouseCameraLook(event):
	rotX += event.relative.x * cameraMouseSensitivity
	rotY += event.relative.y * cameraMouseSensitivity

	# reset rotation every frame
	transform.basis = Basis()
	rotate_object_local(Vector3(0,1,0),-rotX) # first rotate in Y
	rotate_object_local(Vector3(1,0,0),rotY) # then rotate in X
	rotY = clamp(rotY, -.8,.65)

func setJoyStickVelocity(delta):

	if Input.is_action_pressed("rightStickUp"):
		joyPressure.y -= joySensitivity
	elif Input.is_action_pressed("rightStickDown"):
		joyPressure.y += joySensitivity
	if Input.is_action_pressed("rightStickRight"):
		joyPressure.x += joySensitivity
	elif Input.is_action_pressed("rightStickLeft"):
		joyPressure.x -= joySensitivity
	joyPressure.y = clamp(joyPressure.y,-.6,.8)

	
	if joyAxis != Vector3.ZERO:
		joyAxisVelocity  = lerp(joyAxisVelocity, joyPressure, 7*delta )
	else:
		joyAxisVelocity  = lerp(joyAxisVelocity, joyPressure, 3*delta )
		
	joyCameraLook(joyAxisVelocity)


func joyCameraLook(Axis: Vector3):
	transform.basis = Basis()
	rotate_object_local(Vector3(0,1,0),-Axis.x) # first rotate in Y
	rotate_object_local(Vector3(1,0,0),Axis.y)# then rotate in X

func _on_Jump_jumping():
	targetPosition = chaserPositionGround


func _on_Move_moving():
	cameraSpeed = .1
	targetPosition = chaserPosition


func _on_Sprint_sprinting():
	cameraSpeed = .05
	targetPosition = chaserPosition


func _on_Dodge_dodging():
	targetPosition = chaserPosition


func _on_Attack_attacking():
	targetPosition = chaserPosition


func _on_Block_blocking():
	targetPosition = chaserPosition


func _on_Idle_idle():
	targetPosition = chaserPosition


func _on_Timer_timeout():
	automaticFollow = true


func _on_targetDetectionArea_body_entered(body):
	enemies.append(body)


func _on_targetDetectionArea_body_exited(body):
	if body == enemies[currentTarget]:
		currentTarget = 0

	enemies.erase(body)

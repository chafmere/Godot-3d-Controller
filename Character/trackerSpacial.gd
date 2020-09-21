extends Spatial


onready var cameraTween = $cameraTween
onready var chaser = get_parent().get_parent().get_node("characterNodes/chaser")
onready var tracker = $"."

var chaserPosition = Vector3()
var cameraPos = Vector3()
var chaserPositionGround = Vector3()
var targetPosition = chaserPosition
var cameraSpeed

##Mouse Control
var rotX = 0
var rotY = 0
var cameraMouseSensitivity = .001
var mouseSensitivity = cameraMouseSensitivity * 40
var cameraControl

##JoyStick Control
var joyAxis: Vector3
var joyPressure: Vector3
var joyAxisVelocity: Vector3
var joySensitivity = .03
var tryJoyStick: bool


func _ready():
	set_as_toplevel(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta):
	chaserPosition = chaser.get_global_transform().origin
	cameraPos = get_global_transform().origin
	
	chaserPositionGround = Vector3(chaserPosition.x, cameraPos.y , chaserPosition.z)
	
	cameraTween.interpolate_property(tracker,"translation", cameraPos, targetPosition, cameraSpeed,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	cameraTween.start()
	
	if cameraControl:
		joyAxis.y = Input.get_action_strength("rightStickUp")-Input.get_action_strength("rightStickDown")
		joyAxis.x = Input.get_action_strength("rightStickRight")-Input.get_action_strength("rightStickLeft")
		joyAxis = joyAxis.normalized()
		
		if joyAxis != Vector3.ZERO:
			tryJoyStick = true

		if tryJoyStick:
			setJoyStickVelocity(delta)


func _on_character_currentState(state):
	match state:
		0:
			cameraSpeed = .2
			targetPosition = chaserPosition
		2:
			targetPosition = chaserPositionGround
		1:
			cameraSpeed = .1
			targetPosition = chaserPosition
		3:
			targetPosition = chaserPosition
		4:
			targetPosition = chaserPosition
		5:
			targetPosition = chaserPosition


func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if cameraControl:
		if event is InputEventMouseMotion:
			mouseCameraLook(event)
			tryJoyStick = false
			
func mouseCameraLook(event):
	rotX += event.relative.x * cameraMouseSensitivity
	rotY += event.relative.y * cameraMouseSensitivity
	#print(rotY)
	# reset rotation every frame
	transform.basis = Basis()
	rotate_object_local(Vector3(0,1,0),-rotX) # first rotate in Y
	rotate_object_local(Vector3(1,0,0),rotY) # then rotate in X
	rotY = clamp(rotY, -.8,.65)

func setJoyStickVelocity(delta):
	#joyAxisVelocity = lerp(joyAxisVelocity, joyAxis*PI, 1*delta )
	if Input.is_action_pressed("rightStickUp"):
		joyPressure.y += joySensitivity
	elif Input.is_action_pressed("rightStickDown"):
		joyPressure.y -= joySensitivity
	if Input.is_action_pressed("rightStickRight"):
		joyPressure.x -= joySensitivity
	elif Input.is_action_pressed("rightStickLeft"):
		joyPressure.x += joySensitivity
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

func _on_character_freeCamOn(FreeCam):
	cameraControl = FreeCam

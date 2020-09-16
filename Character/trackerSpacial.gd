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


func _ready():
	set_as_toplevel(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta):
	chaserPosition = chaser.get_global_transform().origin
	cameraPos = get_global_transform().origin
	
	chaserPositionGround = Vector3(chaserPosition.x, cameraPos.y , chaserPosition.z)
	
	cameraTween.interpolate_property(tracker,"translation", cameraPos, targetPosition, cameraSpeed,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	cameraTween.start()


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
	print(state)

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if cameraControl:
		if event is InputEventMouseMotion:
			cameraLook(event)

func cameraLook(event):
	rotX += event.relative.x * cameraMouseSensitivity
	rotY += event.relative.y * cameraMouseSensitivity
	# reset rotation every frame
	transform.basis = Basis()
	rotate_object_local(Vector3(0,1,0),-rotX) # first rotate in Y
	rotate_object_local(Vector3(1,0,0),rotY) # then rotate in X
	rotY = clamp(rotY, -.8,.65)


func _on_character_freeCamOn(FreeCam):
	cameraControl = FreeCam

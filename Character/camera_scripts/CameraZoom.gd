extends Camera


var cameraZoomPoint = Vector3()
var cameraZoomOrginal = Vector3(0.00,20.00,-20.00)
var minZoom = Vector3(0.00,10,-10)
var maxZoom = Vector3(0,30,-30)
var cameraCurrentPoint = Vector3()
var zoomSpeed = 2

onready var zoomTween = $zoomTween
onready var mainCamera = $"."
onready var target = get_parent().get_parent().get_parent().get_node("characterNodes/chaser")

# Called when the node enters the scene tree for the first time.
func _ready():
	cameraZoomPoint = cameraZoomOrginal
	cameraCurrentPoint = cameraZoomOrginal

func _process(_delta):
	if Input.is_action_just_released("mouseScrollUp"):
		if cameraZoomPoint == minZoom:
			pass
		else:
			cameraZoomPoint.y -= 1 
			cameraZoomPoint.z += 1
		
	if Input.is_action_just_released("mouseScrollDown"):
		if cameraZoomPoint == maxZoom:
			pass
		else:
			cameraZoomPoint.y += 1
			cameraZoomPoint.z -= 1
#	if Input.is_action_pressed("rightStickDown"):
#		if cameraZoomPoint == maxZoom:
#			pass
#		else:
#			var axis = Input.get_action_strength("rightStickDown")
#			cameraZoomPoint.y = lerp(cameraZoomPoint.y, axis*maxZoom.y, zoomSpeed*delta)
#			cameraZoomPoint.z = lerp(cameraZoomPoint.z, axis*maxZoom.z, zoomSpeed*delta)
#
#	if Input.is_action_pressed("rightStickUp"):
#		if cameraZoomPoint == minZoom:
#			pass
#		else:
#			var axis = Input.get_action_strength("rightStickUp")
#			cameraZoomPoint.y = lerp(cameraZoomPoint.y, axis*minZoom.y, zoomSpeed*delta)
#			cameraZoomPoint.z = lerp(cameraZoomPoint.z, axis*minZoom.z, zoomSpeed*delta)	
###########	TODO Tweak these figures so that zoom with joystick feels good ################
	
	cameraCurrentPoint = mainCamera.get_translation()
	
	zoomTween.interpolate_property(mainCamera,"translation",cameraCurrentPoint,cameraZoomPoint,.002,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	zoomTween.start()
	

	

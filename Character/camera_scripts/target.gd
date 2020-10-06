extends Spatial


onready var trackerTween = $trackerTween
export(NodePath) var characterPath
onready var character= get_node(characterPath)
onready var target = $"."

export var lookAHead: bool
var characterPosition: Vector3
var targetPos: Vector3
var forwardPos: Vector3
var targetSpeed: float

var idle:bool
var blocking:bool

func _ready():
	set_as_toplevel(true)
	targetSpeed = .2
	

func _process(_delta):
	
	characterPosition = character.get_global_transform().origin
	forwardPos = character.get_global_transform().basis.z
	if lookAHead:
		targetPos = get_global_transform().origin
		targetSpeed = .001
	elif !idle:
		targetPos = get_global_transform().origin + forwardPos
	else:
		targetPos = get_global_transform().origin
		
	trackerTween.interpolate_property(target,"translation", targetPos, characterPosition, targetSpeed,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	trackerTween.start()	


func _on_tracker_cameraControl(cameraControl):
	lookAHead = cameraControl


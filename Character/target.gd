extends Spatial


onready var trackerTween = $trackerTween
onready var character= get_parent()
onready var target = $"."

var lookAHead: bool
var characterPosition: Vector3
var targetPos: Vector3
var forwardPos: Vector3
var targetSpeed: float


func _ready():
	set_as_toplevel(true)
	targetSpeed = .3
	

func _process(_delta):
	
	characterPosition = character.get_global_transform().origin
	
	if lookAHead:
		targetPos = get_global_transform().origin
		targetSpeed = .001
	else:
		targetPos = get_global_transform().origin + forwardPos
	
	trackerTween.interpolate_property(target,"translation", targetPos, characterPosition, targetSpeed,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	trackerTween.start()	

func _on_character_currentDirection(direction):
	forwardPos = direction

func _on_character_freeCamOn(FreeCam):
	lookAHead = FreeCam

extends Spatial

export(NodePath) var mainObjectPath
export(NodePath) var trackerPath
onready var mainObject = get_node(mainObjectPath)
onready var heightObject = get_node(trackerPath)
onready var lookTarget = $"."
onready var tween = $looktween
var offsetDistance = 20
var offsetheight: float
var behindPlayer

var mainObjectLocation: Vector3
var position: Vector3
var travel:Vector3

func _ready():
	set_as_toplevel(true)


func _process(delta):
	
	if Input.is_action_just_pressed("target"):
		resetLocation()
	else:
		var target = mainObject.get_global_transform().origin
		var pos = get_global_transform().origin
		var up = Vector3(0,1,0)
		var offset = pos - target
		var trackerHeight = heightObject.get_global_transform().origin
		offsetheight = trackerHeight.y
		
		offset = offset.normalized()*offsetDistance
		pos = target + offset
		pos.y = offsetheight
		look_at_from_position(pos,target,up)
	
func resetLocation():
	mainObjectLocation = mainObject.get_global_transform().origin
	behindPlayer = -mainObject.get_global_transform().basis.z
	#mainObjectLocation = mainObjectLocation.normalized()

	position = get_global_transform().origin

	travel = mainObjectLocation + (behindPlayer*offsetDistance)
#
	tween.interpolate_property(lookTarget,"translation",position,travel,.2,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.start()	

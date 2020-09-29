extends "res://Character/states/states.gd"

onready var animTree = get_parent().get_parent().get_node("AnimationTree")
onready var animState = animTree.get("parameters/playback")
onready var character = get_parent().get_parent().get_node("characterNodes")
export(NodePath) var targetDetectionArea
export(NodePath) var cameraPath
onready var camera = get_node(cameraPath)
onready var targetArea = get_node(targetDetectionArea)

signal blocking

var angleDifference
var direction: Vector3
var enemies: Array
var targetIcon
var mainTarget
var targetLocation:Vector3
var characterLocation:Vector3
var characterRotation: Vector3
var velocity: Vector3
var acceleration = 10
var UP = Vector3(0,1,0)
var blockMoveSpeed = 5
var cameraLocation
var currentTarget = 0
var totaltargets: int

func enter():
	animState.travel("block")
	var TargetIcon = load("res://enemy/TargetIndicator.tscn")
	targetIcon = TargetIcon.instance()
	var world = get_tree().current_scene
	world.add_child(targetIcon)
	

func update(delta):
	emit_signal("blocking")
	
	var tracker = get_parent().get_parent().get_node("cameraRig/tracker")
	cameraLocation = camera.get_global_transform().origin

	if enemies.empty():
		pass
	else:
		focusTarget()
		if Input.is_action_just_pressed("targetSwitch"):
			nextTarget()

		
	
	direction = get_input_direction()
	
	move(blockMoveSpeed,direction,delta)
	
	
		
	if Input.is_action_just_released("block"):
		targetIcon.queue_free()
		currentTarget = 0
		velocity = Vector3.ZERO
		character.set_rotation(Vector3(0,targetLocation.z,0))
		emit_signal("finished", "idle")



func focusTarget():
	mainTarget = enemies[currentTarget]
	targetLocation = mainTarget.get_global_transform().origin
	targetLocation = Vector3(targetLocation.x,0,targetLocation.z)
	
	characterRotation = character.get_rotation()
	characterLocation = character.transform.basis.z

	targetIcon.global_transform = mainTarget.get_global_transform()
	targetIcon.look_at(cameraLocation, UP)
	character.look_at(targetLocation, UP)
	character.rotate_object_local(Vector3(0,1,0),3.14)


func nextTarget():
	totaltargets = enemies.size()-1
	
	if currentTarget >= totaltargets:
		currentTarget = 0
	else:
		currentTarget = currentTarget+1
	print(currentTarget)

func _on_Area_body_entered(body):
	enemies.append(body)


func _on_Area_body_exited(body):
	enemies.erase(body)
	
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

func move(speed, direction, delta):
	velocity.x = move_toward(velocity.x, direction.x*speed, acceleration*delta) 
	velocity.z = move_toward(velocity.z, direction.z*speed, acceleration*delta) 
	velocity = owner.move_and_slide(velocity, UP)


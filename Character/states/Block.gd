extends "res://Character/states/states.gd"

onready var animTree = get_parent().get_parent().get_node("AnimationTree")
onready var animState = animTree.get("parameters/playback")
onready var character = get_parent().get_parent().get_node("characterNodes")
export(NodePath) var targetDetectionArea
#export(NodePath) var cameraPath
#onready var camera = get_node(cameraPath)
onready var targetArea = get_node(targetDetectionArea)

signal blocking

var angleDifference
var direction: Vector3
#var enemies: Array
#var targetIcon
#var mainTarget
#var targetLocation:Vector3
#var characterLocation:Vector3
var characterRotation: Vector3
var velocity: Vector3
var acceleration = 10
var UP = Vector3(0,1,0)
var blockMoveSpeed = 5
#var cameraLocation
#var currentTarget = 0
var totaltargets: int

func enter():
	animState.travel("block")
	#var TargetIcon = load("res://enemy/TargetIndicator.tscn")
	#targetIcon = TargetIcon.instance()
	#var world = get_tree().current_scene
	#world.add_child(targetIcon)

func handle_input(event):
	if event.is_action_pressed("dodge"):
		#targetIcon.queue_free()
		emit_signal("finished", "dodge")
	if event.is_action_pressed("attack"):
		#targetIcon.queue_free()
		emit_signal("finished", "attack")
	if event.is_action_pressed("ui_accept"):
		pass
		#targetIcon.queue_free()
		
func update(delta):
	
	direction = get_input_direction()

	emit_signal("blocking")

		
	move(blockMoveSpeed,direction,delta)
	rotatePlayer(direction)
	
	if Input.is_action_just_released("block"):
		emit_signal("blocking")
		velocity = Vector3.ZERO
		emit_signal("finished", "idle")

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



#func _on_targetDetectionArea_body_entered(body):
#	enemies.append(body)


#func _on_targetDetectionArea_body_exited(body):
#	if body == enemies[currentTarget]:
#		currentTarget = 0
#
#	enemies.erase(body)

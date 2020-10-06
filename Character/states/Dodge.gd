extends "res://Character/states/motion.gd"

export var dodgeSpeed = 50
var dodge_direction
var inputDirection
signal dodging

func initialize(currentVelocity):
	velocity = currentVelocity

func enter():
	animState.travel("dodge")
	swordsInForTheBoys()

func handle_input(event):
	return .handle_input(event)

func update(delta):
	_gravity()
	emit_signal("dodging")
	inputDirection = get_input_direction()
	if inputDirection == Vector3.ZERO:
		dodge_direction = character.transform.basis.z
	else:
		dodge_direction = inputDirection
		_rotatePlayer(dodge_direction)
	
	_move(dodgeSpeed, dodge_direction, delta)
	
func dodgeEnd():
	velocity = Vector3.ZERO
	emit_signal("finished", "previous")

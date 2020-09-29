extends "res://Character/states/motion.gd"

export var dodgeSpeed = 50
var dodge_direction
signal dodging

func initialize(currentVelocity):
	velocity = currentVelocity

func enter():
	animState.travel("dodge")
	swordsInForTheBoys()

func handle_input(event):
	return .handle_input(event)

func update(delta):
	emit_signal("dodging")

	dodge_direction = character.transform.basis.z
	
	_move(dodgeSpeed, dodge_direction, delta)
	
func dodgeEnd():
	velocity = Vector3.ZERO
	emit_signal("finished", "move")

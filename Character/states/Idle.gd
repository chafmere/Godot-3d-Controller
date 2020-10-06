extends "res://Character/states/on_ground.gd"

signal idle

func initialize(currentVelocity):
	velocity = currentVelocity

func enter():
	animState.travel("idlerun")
	putSwordInTimer()
	
func handle_input(event):
	return .handle_input(event)
	
func update(delta):
	emit_signal("idle")
	animTree.set("parameters/idlerun/idleBlend/blend_amount", 0.00)
	animTree.set("parameters/idlerun/sprintBlend/blend_amount", 0.00)
	
	var input_direction = get_input_direction()
	_gravity()

	if input_direction:
		emit_signal("finished", "move")
	
	_move(speed, input_direction, delta)

extends "res://Character/states/on_ground.gd"

signal moving

func initialize(currentVelocity):
	velocity = currentVelocity

func enter():
	animState.travel("idlerun")
	animTree.set("parameters/idlerun/sprintBlend/blend_amount", 0.00)
	putSwordInTimer()
	
func handle_input(event):
	return .handle_input(event)
	
func update(delta):
	emit_signal("moving")
	var input_direction = get_input_direction()
	
	if not input_direction:
		emit_signal("finished", "idle")
		
	_rotatePlayer(input_direction)
	_gravity()
	_move(speed, input_direction, delta)

	animTree.set("parameters/idlerun/idleBlend/blend_amount", velocity.length()/speed)

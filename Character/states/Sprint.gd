extends "res://Character/states/on_ground.gd"

signal sprinting

func initialize(currentVelocity):
	velocity = currentVelocity

func enter():
	swordsInForTheBoys()
	animState.travel("idlerun")	
	
func handle_input(event):
	if event.is_action_released("sprintKey"):
		emit_signal("finished", "move")
	return .handle_input(event)
	
func update(delta):
	emit_signal("sprinting")
	_gravity()
	
	var input_direction = get_input_direction()

	_rotatePlayer(input_direction)
		
	_move(sprintSpeed, input_direction, delta)
	
	animTree.set("parameters/idlerun/idleBlend/blend_amount", velocity.length()/sprintSpeed)
	animTree.set("parameters/idlerun/sprintBlend/blend_amount",  velocity.length()/sprintSpeed)
	


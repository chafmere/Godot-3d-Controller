extends "res://Character/states/motion.gd"

var jumpVelocity
signal jumping

func initialize(currentVelocity):
	velocity = currentVelocity

func enter():
	jumpVelocity = (abs(GRAVITY) * timeToJumpApex)*25
	velocity.y = jumpVelocity
	animState.travel("jump")
	
	
func update(delta):
	emit_signal("jumping")
	if Input.is_action_just_released("ui_accept") && velocity.y > 20:
		velocity.y = 0
	else:
		var input_direction = get_input_direction()
		_gravity()
		_move(speed, input_direction, delta)
		
		if velocity.y < 0 && floorGang.is_colliding():
			emit_signal("finished", "previous")
			_rotatePlayer(input_direction)

		
	

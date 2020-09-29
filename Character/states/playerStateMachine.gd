extends "res://Character/states/state_machine.gd"

func _ready():
	states_map = {
		"idle": $Idle,
		"move": $Move,
		"sprint": $Sprint,
		"dodge": $Dodge,
		"jump": $Jump,
		"attack": $Attack,
		"block": $Block
	}
	
func _change_state(state_name):
	"""
	The base state_machine interface this node extends does most of the work
	"""
	if not _active:
		return
	#if state_name in ["block", "jump", "attack"]: ##Check behaviour and return if necessary.
	#	states_stack.push_front(states_map[state_name])
	if state_name == "sprint" and current_state == $Move:
		$Sprint.initialize($Move.velocity)
	if state_name == "move" and current_state == $Sprint || current_state == $Idle:
		if current_state == $Sprint:
			$Move.initialize($Sprint.velocity)
		if current_state == $Idle:
			$Move.initialize($Idle.velocity)
	if state_name == "idle" and current_state == $Move:
		$Idle.initialize($Move.velocity)
	if state_name == "jump" and current_state == $Move || current_state == $Sprint:
		if current_state == $Move:
			$Jump.initialize($Move.velocity)
		elif current_state == $Sprint:
			$Jump.initialize($Sprint.velocity)
	if state_name == "dodge" and current_state == $Move || current_state == $Sprint:
		if current_state == $Move:
			$Dodge.initialize($Move.velocity)
		elif current_state == $Sprint:
			$Dodge.initialize($Sprint.velocity)
	._change_state(state_name)

func _input(event):
	if event.is_action_pressed("attack"):
		if current_state == $Attack:
			return
		_change_state("attack")
		return
	current_state.handle_input(event)

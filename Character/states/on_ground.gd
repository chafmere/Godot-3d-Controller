extends "res://Character/states/motion.gd"



func handle_input(event):
	if event.is_action_pressed("ui_accept") && floorGang.is_colliding():
		emit_signal("finished", "jump")
		
	if event.is_action_pressed("dodge"):
		emit_signal("finished", "dodge")
		
	if event.is_action_pressed("attack"):
		emit_signal("finished", "attack")
		
	if event.is_action_pressed("sprintKey"):
		emit_signal("finished", "sprint")
		
	if event.is_action_pressed("block"):
		emit_signal("finished", "block")
	return .handle_input(event)

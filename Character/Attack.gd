extends "res://Character/states/states.gd"

onready var animTree = get_parent().get_parent().get_node("AnimationTree")
onready var animState = animTree.get("parameters/playback")
onready var character = get_parent().get_parent().get_node("characterNodes")
var currentAnimation

var attackCombo: int

signal attacking

func enter():
	
	animState.travel("powerSword")
	attackCombo = 0
	
func onAttackEnd():
	attackCombo = 0
	emit_signal("finished", "idle")
	swordsOutForTheBoys()
	
func update(delta):
	currentAnimation =	animState.get_current_node()
	if Input.is_action_just_released("attack") && attackCombo == 0:
		attackCombo = attackCombo+1
		animState.travel("attack1")
		print(attackCombo)
	elif Input.is_action_just_released("attack") && attackCombo == 1:
		animState.travel("attack2")
		attackCombo = attackCombo+1
		print(attackCombo)
	elif Input.is_action_just_released("attack") && attackCombo == 2:
		animState.travel("attack3")
		attackCombo = 0
		print(attackCombo)
	elif Input.is_action_pressed("attack") && attackCombo == 0:
		animState.travel("powerSword")
	elif currentAnimation == "idlerun":
		attackCombo = 0
		emit_signal("finished", "idle")
		print("attack exiting")
		swordsOutForTheBoys()
		
	emit_signal("attacking")
	
func swordsOutForTheBoys():
	animTree.set("parameters/idlerun/idleAttack/blend_amount", 1.00)
	animTree.set("parameters/idlerun/runAttack/blend_amount", 1.00)
	animTree.set("parameters/jump/jumpAttack/blend_amount", 1.00)
	

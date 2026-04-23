extends Node2D

@export var ring_scene: PackedScene

func _ready():
	GameManager.rings = 0
	
	if GameManager.is_ai_mode:
		var ai = $Player/AIController2D
		if ai:
			ai.control_mode = AIController2D.ControlModes.TRAINING
	else:
		GameManager.is_ai_mode = false
		var transition = preload("res://scenes/ui/ZoneTransition.tscn").instantiate()
		add_child(transition)
		await transition.show_transition("GREEN ZONE", "ACT 2")

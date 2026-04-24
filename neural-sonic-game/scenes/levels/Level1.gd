extends Node2D

@export var ring_scene: PackedScene

func _ready():
	GameManager.rings = 0
	
	if GameManager.is_ai_mode:
		$Sync.control_mode = Sync.ControlModes.TRAINING
		var ai = $Player/AIController2D
		if ai:
			ai.control_mode = AIController2D.ControlModes.TRAINING
	else:
		$Sync.control_mode = Sync.ControlModes.HUMAN
		var transition = preload("res://scenes/ui/ZoneTransition.tscn").instantiate()
		add_child(transition)
		await transition.show_transition("PINK ZONE", "ACT 1")

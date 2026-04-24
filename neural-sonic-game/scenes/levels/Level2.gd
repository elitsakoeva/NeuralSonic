extends Node2D

@export var ring_scene: PackedScene

func _ready():
	GameManager.rings = 0
	
	if GameManager.is_ai_mode:
		$Player/AIController2D.control_mode = AIController2D.ControlModes.TRAINING
		$Player.visible = true
		return
	
	$Player/AIController2D.control_mode = AIController2D.ControlModes.HUMAN
	
	if not GameManager.is_reloading:
		var transition = preload("res://scenes/ui/ZoneTransition.tscn").instantiate()
		add_child(transition)
		await transition.show_transition("GREEN ZONE", "ACT 2")
	
	GameManager.is_reloading = false
	$Player.visible = true

extends Node2D

@export var ring_scene: PackedScene

func _ready():
	GameManager.is_ai_mode = true
	GameManager.rings = 0
	
	if not GameManager.is_ai_mode:
		var transition = preload("res://scenes/ui/ZoneTransition.tscn").instantiate()
		add_child(transition)
		await transition.show_transition("PINK ZONE", "ACT 1")

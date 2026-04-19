extends Node2D

@export var ring_scene: PackedScene

func _ready():
	GameManager.rings = 0
	var transition = preload("res://scenes/ui/ZoneTransition.tscn").instantiate()
	add_child(transition)
	await transition.show_transition("GREEN ZONE", "ACT 1")

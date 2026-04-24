extends Node2D

@export var ring_scene: PackedScene

func _ready():
	GameManager.rings = 0
	
	if GameManager.is_ai_mode:
		var sync = Node.new()
		sync.set_script(load("res://addons/godot_rl_agents/sync.gd"))
		sync.name = "Sync"
		add_child(sync)
		$Player/AIController2D.control_mode = AIController2D.ControlModes.TRAINING
		$Player.visible = true
		return
	

	$Player/AIController2D.control_mode = AIController2D.ControlModes.HUMAN
	
	if not GameManager.is_reloading:
		var transition = preload("res://scenes/ui/ZoneTransition.tscn").instantiate()
		add_child(transition)
		await transition.show_transition("CYAN ZONE", "ACT 3")
	
	GameManager.is_reloading = false
	$Player.visible = true

extends Control

@onready var play_button = $Play
@onready var ai_button = $AIMode
@onready var exit_button = $Exit


func _ready():
	if GameManager.pending_switch:
		GameManager.pending_switch = false
		if GameManager.is_ai_mode:
			var project_path = ProjectSettings.globalize_path("res://")
			var train_script = project_path + "ai_training/train.py"
			OS.create_process("py", ["-3.11", train_script])
		get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn")
		return
	
	play_button.pressed.connect(_on_play_pressed)
	ai_button.pressed.connect(_on_ai_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_play_pressed():
	GameManager.is_ai_mode = false
	get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn")

func _on_ai_pressed():
	GameManager.is_ai_mode = true
	var project_path = ProjectSettings.globalize_path("res://")
	var train_script = project_path + "ai_training/train.py"
	OS.create_process("py", ["-3.11", train_script])
	get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn")

func _on_exit_pressed():
	get_tree().quit()

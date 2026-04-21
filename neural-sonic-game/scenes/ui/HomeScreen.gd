extends Control

@onready var play_button = $Play
@onready var ai_button = $AIMode
@onready var exit_button = $Exit


func _ready():
	play_button.pressed.connect(_on_play_pressed)
	ai_button.pressed.connect(_on_ai_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_play_pressed():
	GameManager.is_ai_mode = false
	get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn")

func _on_ai_pressed():
	GameManager.is_ai_mode = true
	get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn")

func _on_exit_pressed():
	get_tree().quit()

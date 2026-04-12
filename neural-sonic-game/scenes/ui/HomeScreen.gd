extends Control

@onready var play_button = $VBoxContainer/Play
@onready var ai_button = $VBoxContainer/AIMode
@onready var settings_button = $VBoxContainer/Settings


func _ready():
	play_button.pressed.connect(_on_play_pressed)
	ai_button.pressed.connect(_on_ai_pressed)
	settings_button.pressed.connect(_on_settings_pressed)

func _on_play_pressed():
	GameManager.is_ai_mode = false
	get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn")

func _on_ai_pressed():
	GameManager.is_ai_mode = true
	get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn")

func _on_settings_pressed():
	pass

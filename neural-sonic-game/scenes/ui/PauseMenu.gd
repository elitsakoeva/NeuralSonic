extends CanvasLayer

@onready var mode_label = $PanelContainer/VBoxContainer/ModeLabel
@onready var resume_button = $PanelContainer/VBoxContainer/ResumeButton
@onready var switch_button = $PanelContainer/VBoxContainer/SwitchButton
@onready var exit_button = $PanelContainer/VBoxContainer/ExitButton

func _ready():
	if GameManager.is_ai_mode:
		mode_label.text = "AI MODE"
		switch_button.text = "Switch to Player Mode"
	else:
		mode_label.text = "PLAYER MODE"
		switch_button.text = "Switch to AI Mode"
	
	resume_button.pressed.connect(_on_resume)
	switch_button.pressed.connect(_on_switch)
	exit_button.pressed.connect(_on_exit)
	resume_button.grab_focus()

func _on_resume():
	get_tree().paused = false
	queue_free()

func _on_switch():
	get_tree().paused = false
	GameManager.is_ai_mode = not GameManager.is_ai_mode
	GameManager.pending_switch = true
	queue_free()
	get_tree().change_scene_to_file("res://scenes/ui/HomeScreen.tscn")

func _on_exit():
	get_tree().paused = false
	get_tree().quit()

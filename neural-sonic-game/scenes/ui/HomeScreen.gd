extends Control

@onready var play_button = $Play
@onready var ai_button = $AIMode
@onready var exit_button = $Exit

func _ready():
	if GameManager.pending_switch:
		GameManager.pending_switch = false
		if GameManager.is_ai_mode:
			$LoadingLabel.text = "Training with your moves..."
			$LoadingLabel.visible = true
			$Play.visible = false
			$AIMode.visible = false
			$Exit.visible = false
			var project_path = ProjectSettings.globalize_path("res://")
			var bc_script = project_path + "ai_training/behavioral_cloning.py"
			var train_script = project_path + "ai_training/train.py"
			var output = []
			OS.execute("python", [bc_script], output, true)
			GameManager.ai_process_id = OS.create_process("python", [train_script])
			await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn")
		return
	
	play_button.pressed.connect(_on_play_pressed)
	ai_button.pressed.connect(_on_ai_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _wait_for_server():
	var connected = false
	while not connected:
		var tcp = TCPServer.new()
		var err = tcp.listen(11008, "127.0.0.1")
		if err != OK:
			connected = true
		else:
			tcp.stop()
			await get_tree().create_timer(0.5).timeout
func _on_play_pressed():
	GameManager.is_ai_mode = false
	get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn")

func _on_ai_pressed():
	GameManager.is_ai_mode = true
	var project_path = ProjectSettings.globalize_path("res://")
	var train_script = project_path + "ai_training/train.py"
	GameManager.ai_process_id = OS.create_process("py", ["-3.11", train_script])
	get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn")

func _on_exit_pressed():
	get_tree().quit()

extends Area2D

@export var next_level: String = ""

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is CharacterBody2D:
		var ai = body.get_node_or_null("AIController2D")
		if ai and GameManager.is_ai_mode:
			ai.reward += 1000.0
			ai.done = true
			body.position = Vector2(0, 30)
			body.velocity = Vector2.ZERO
			return
	   
		if next_level == "":
			get_tree().change_scene_to_file("res://scenes/ui/FinalScreen.tscn")
		else:
			get_tree().change_scene_to_file(next_level)

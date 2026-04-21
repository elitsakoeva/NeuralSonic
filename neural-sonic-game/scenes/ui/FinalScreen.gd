extends Node2D

@onready var player = $Player
@onready var sprite = $Player/AnimatedSprite2D
@onready var canvas = $CanvasLayer
@onready var you_won = $CanvasLayer/YouWon
@onready var menu_button = $CanvasLayer/MainMenu

var start_x = -100.0
var target_x = 576.0  

func _ready():
	you_won.visible = false
	menu_button.visible = false
	
	player.position.x = start_x
	player.position.y = 400 
	player.set_physics_process(false)
	sprite.flip_h = false
	sprite.scale = Vector2(1.0, 1.0)
	sprite.play("run_fast")
	
	_run_to_center()
	
	menu_button.pressed.connect(_on_menu_pressed)

func _run_to_center():
	
	var tween = create_tween()
	tween.tween_property(player, "position:x", target_x, 1.0).set_ease(Tween.EASE_OUT)
	await tween.finished
	
	
	sprite.scale = Vector2(0.1, 0.1) 
	sprite.play("victory")

	
	
	await get_tree().create_timer(0.8).timeout
	_show_results()

func _show_results():
	you_won.visible = true
	you_won.modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(you_won, "modulate:a", 1.0, 1.0)
	await tween.finished
	
	await get_tree().create_timer(1.0).timeout
	menu_button.visible = true

func _on_menu_pressed():
	GameManager.rings = 0
	GameManager.lives = 3
	get_tree().change_scene_to_file("res://scenes/ui/HomeScreen.tscn")

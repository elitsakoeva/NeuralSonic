extends CanvasLayer

@onready var death_label = $YouDied
@onready var color_rect = $ColorRect
@onready var player = $Player
@onready var sprite = $Player/AnimatedSprite2D

func show_death(level_path: String):
	visible = true
	death_label.modulate.a = 0.0
	color_rect.modulate.a = 0.0
	player.modulate.a = 0.0
	color_rect.color = Color.BLACK
	player.set_physics_process(false)
	player.scale = Vector2(1.0, 1.0)
	sprite.play("you_died")
	

	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.visible = false
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(color_rect, "modulate:a", 1.0, 0.8)
	tween.tween_property(player, "modulate:a", 1.0, 0.8).set_delay(0.3)
	tween.tween_property(death_label, "modulate:a", 1.0, 0.8).set_delay(0.5)
	await tween.finished
	
	await get_tree().create_timer(2.0).timeout
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(death_label, "modulate:a", 0.0, 0.4)
	tween.tween_property(player, "modulate:a", 0.0, 0.4)
	await tween.finished
	
	var trans = preload("res://scenes/ui/ZoneTransition.tscn").instantiate()
	get_tree().root.add_child(trans)
	var zone = "PINK ZONE"
	var act = "ACT 1"
	if "Level2" in level_path:
		zone = "GREEN ZONE"
		act = "ACT 2"
	elif "Level3" in level_path:
		zone = "CYAN ZONE"
		act = "ACT 3"
	
	GameManager.is_reloading = true
	await trans.show_transition(zone, act)
	
	queue_free()
	get_tree().change_scene_to_file.call_deferred(level_path)

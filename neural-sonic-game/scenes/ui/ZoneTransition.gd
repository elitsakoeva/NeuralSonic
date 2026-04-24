extends CanvasLayer

@onready var zone_name_label = $ZoneName
@onready var zone_act_label = $ZoneAct
@onready var color_rect = $ColorRect

signal transition_finished

func show_transition(zone: String, act: String):
	zone_name_label.text = zone
	zone_act_label.text = act
	visible = true
	color_rect.modulate.a = 1.0
	
	zone_name_label.position.x = -600
	zone_act_label.position.x = -600
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(zone_name_label, "position:x", 200, 0.6).set_ease(Tween.EASE_OUT)
	tween.tween_property(zone_act_label, "position:x", 300, 0.6).set_ease(Tween.EASE_OUT).set_delay(0.1)
	await tween.finished
	
	await get_tree().create_timer(2.0).timeout
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(zone_name_label, "position:x", 1200, 0.5).set_ease(Tween.EASE_IN)
	tween.tween_property(zone_act_label, "position:x", 1200, 0.5).set_ease(Tween.EASE_IN).set_delay(0.1)
	await tween.finished
	
	color_rect.modulate.a = 1.0
	color_rect.color = Color.BLACK
	await get_tree().create_timer(0.1).timeout
	visible = false
	emit_signal("transition_finished")

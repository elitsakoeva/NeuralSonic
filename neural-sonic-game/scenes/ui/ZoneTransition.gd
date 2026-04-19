extends CanvasLayer

@onready var zone_name = $ZoneName
@onready var zone_act = $ZoneAct
@onready var color_rect = $ColorRect

signal transition_finished

func show_transition(name: String, act: String):
	zone_name.text = name
	zone_act.text = act
	visible = true
	
	
	zone_name.position.x = -600
	zone_act.position.x = -600
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(zone_name, "position:x", 200, 0.6).set_ease(Tween.EASE_OUT)
	tween.tween_property(zone_act, "position:x", 300, 0.6).set_ease(Tween.EASE_OUT).set_delay(0.1)
	await tween.finished
	
	await get_tree().create_timer(2.0).timeout
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(zone_name, "position:x", 1200, 0.5).set_ease(Tween.EASE_IN)
	tween.tween_property(zone_act, "position:x", 1200, 0.5).set_ease(Tween.EASE_IN).set_delay(0.1)
	await tween.finished
	
	tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, 0.4)
	await tween.finished
	
	visible = false
	emit_signal("transition_finished")

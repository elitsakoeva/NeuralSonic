extends Area2D

const SPRING_FORCE = -600.0
var is_bouncing = false

func _ready():
	body_entered.connect(_on_body_entered)
	$AnimatedSprite2D.play("idle")
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)

func _on_body_entered(body):
	if body.name == "Player" and not is_bouncing:
		is_bouncing = true
		body.velocity.y = SPRING_FORCE
		$AnimatedSprite2D.play("bounce")

func _on_animation_finished():
	if $AnimatedSprite2D.animation == "bounce":
		$AnimatedSprite2D.play("idle")
		is_bouncing = false

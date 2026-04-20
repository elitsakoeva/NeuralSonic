extends Area2D

const SPRING_FORCE = -600.0

func _ready():
	body_entered.connect(_on_body_entered)
	$AnimatedSprite2D.play("idle")

func _on_body_entered(body):
	if body.name == "Player":
		body.velocity.y = SPRING_FORCE
		$AnimatedSprite2D.play("bounce")
		await $AnimatedSprite2D.animation_finished
		$AnimatedSprite2D.play("idle")

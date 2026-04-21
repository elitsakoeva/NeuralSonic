extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		var knockback_dir = sign(body.global_position.x - global_position.x)
		body.hit_spike(knockback_dir)

extends Area2D

func _ready():
	$AnimatedSprite2D.play("spin")
	body_entered.connect(_on_body_entered)
	
	
func _on_body_entered(body):
	if body.name == "Player":
		GameManager.rings += 1
		queue_free()

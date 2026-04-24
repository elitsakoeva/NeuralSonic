extends Area2D

var velocity = Vector2.ZERO
var ring_gravity = 300.0
var can_collect = true

func _ready():
	add_to_group("rings")
	$AnimatedSprite2D.play("spin")
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	if velocity != Vector2.ZERO:
		velocity.y += ring_gravity * delta
		position += velocity * delta
		
		if position.y > 2000:
			queue_free()
			return

func launch(vel: Vector2):
	can_collect = false
	velocity = vel
	set_physics_process(true)
	if is_inside_tree():
		await get_tree().create_timer(1.0).timeout
		if is_inside_tree():
			can_collect = true
		await get_tree().create_timer(4.0).timeout
		if is_inside_tree():
			queue_free()

func _on_body_entered(body):
	if body.name == "Player" and can_collect:
		GameManager.rings += 1
		queue_free()

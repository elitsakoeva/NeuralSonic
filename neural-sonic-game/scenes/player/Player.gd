extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = - 350.0
const ACCELERATION = 10.0
const FRICTION = 8.0
const GRAVITY = 900.0

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION)

	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION)

	move_and_slide()

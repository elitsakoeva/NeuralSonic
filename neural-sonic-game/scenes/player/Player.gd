extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dead: bool = false
var is_hit: bool = false
var current_level_path: String = ""

@onready var sprite = $AnimatedSprite2D

func _ready():
	current_level_path = get_tree().current_scene.scene_file_path

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	
	if not GameManager.is_ai_mode:
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
			sprite.flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if is_hit:
		sprite.play("hit")
	elif not is_on_floor():
		sprite.play("jump")
	elif velocity.x != 0:
		sprite.play("run")
	else:
		sprite.play("idle")
	
	move_and_slide()

func die():
	if is_dead:
		return
	
	is_dead = true
	set_physics_process(false)
	
	var ai = get_node_or_null("AIController2D")
	if ai:
		ai.reward -= 5.0
		ai.done = true
		position = Vector2(0, 30)
		velocity = Vector2.ZERO
		is_dead = false
		set_physics_process(true)
		return
	
	sprite.play("death")
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 25, 0.2)
	await get_tree().create_timer(0.5).timeout
	
	GameManager.lives -= 1
	if GameManager.lives <= 0:
		GameManager.lives = 3
		GameManager.rings = 0
		var death_screen = preload("res://scenes/ui/DeathScreen.tscn").instantiate()
		get_tree().root.add_child(death_screen)
		await death_screen.show_death(current_level_path)
	else:
		get_tree().reload_current_scene()
		
func hit_spike(knockback_dir: int = 1):
	if is_dead or is_hit:
		return
	
	if GameManager.rings <= 0:
		die()
		return
	
	is_hit = true
	sprite.play("hit")
	
	velocity.y = -150.0
	velocity.x = knockback_dir * 250.0
	
	_scatter_rings()
	GameManager.rings = 0
	
	await get_tree().create_timer(0.5).timeout
	is_hit = false

func _scatter_rings():
	var ring_scene = preload("res://scenes/environment/Ring.tscn")
	var ring_count = min(GameManager.rings, 20)
	
	for i in range(ring_count):
		var ring = ring_scene.instantiate()
		get_parent().add_child(ring)
		ring.global_position = global_position
		var angle = (i / float(ring_count)) * TAU
		var speed = randf_range(100, 200)
		ring.launch(Vector2(cos(angle), sin(angle)) * speed)


func ai_move(direction: int):
	print("ai_move called with: ", direction)
	if direction != 0:
		velocity.x = direction * SPEED
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func ai_jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY

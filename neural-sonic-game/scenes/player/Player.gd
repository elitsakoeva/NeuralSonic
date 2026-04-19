extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dead: bool = false
var current_level_path: String = ""

@onready var sprite = $AnimatedSprite2D

func _ready():
	current_level_path = get_tree().current_scene.scene_file_path

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if not is_on_floor():
		sprite.play("jump")
	elif direction != 0:
		sprite.play("run")
	else:
		sprite.play("idle")
	move_and_slide()

func die():
	if is_dead:
		return
	is_dead = true
	sprite.play("death")
	set_physics_process(false)
	
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 60, 0.3)
	tween.tween_property(self, "position:y", position.y + 20, 0.2)
	
	await get_tree().create_timer(1.0).timeout
	
	GameManager.lives -= 1
	if GameManager.lives <= 0:
		GameManager.lives = 3
		GameManager.rings = 0
		var death_screen = preload("res://scenes/ui/DeathScreen.tscn").instantiate()
		get_tree().root.add_child(death_screen)
		await death_screen.show_death(current_level_path)
	else:
		get_tree().reload_current_scene()

extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dead: bool = false
var is_hit: bool = false
var current_level_path: String = ""

var pause_menu_scene = preload("res://scenes/ui/PauseMenu.tscn")
var pause_menu_instance = null

var recording: bool = false
var recorded_data: Array = []

@onready var sprite = $AnimatedSprite2D

func _ready():
	if not GameManager.is_ai_mode:
		recording = true
	
	current_level_path = get_tree().current_scene.scene_file_path
	is_hit = false
	is_dead = false
	sprite.play("idle")
	visible = false

	if GameManager.is_reloading:
		set_physics_process(false)
		await get_tree().create_timer(0.5).timeout
		set_physics_process(true)
		
		

func _record_step():
	if not recording:
		return
	
	var player = self
	var space_state = get_world_2d().direct_space_state
	var ray_right = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + Vector2(100, 0)
	)
	var ray_down = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + Vector2(0, 100)
	)
	var result_right = space_state.intersect_ray(ray_right)
	var result_down = space_state.intersect_ray(ray_down)
	
	var obs = [
		position.x / 1000.0,
		position.y / 500.0,
		velocity.x / 150.0,
		velocity.y / 300.0,
		float(is_on_floor()),
		float(result_right.size() > 0),
		float(result_down.size() > 0),
	]
	
	var move = 0
	var jump = 0
	if Input.is_action_pressed("ui_right"):
		move = 1
	if Input.is_action_just_pressed("ui_accept"):
		jump = 1
	
	recorded_data.append({
		"obs": obs,
		"move": move,
		"jump": jump
	})
		
		

func save_recording():
	if recorded_data.is_empty():
		return
	
	var file = FileAccess.open("res://ai_training/recordings/demo.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(recorded_data))
		file.close()
		print("saved %d steps." % recorded_data.size())
		recorded_data = []
		
func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if get_tree().paused:
				_close_pause_menu()
			else:
				_open_pause_menu()

func _open_pause_menu():
	if pause_menu_instance != null:
		return
	get_tree().paused = true
	pause_menu_instance = pause_menu_scene.instantiate()
	pause_menu_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(pause_menu_instance)

func _close_pause_menu():
	if pause_menu_instance:
		pause_menu_instance.queue_free()
		pause_menu_instance = null
	get_tree().paused = false
	 

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
		_record_step()
	
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
	save_recording()
	sprite.play("death")
	set_physics_process(false)
	
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 25, 0.2)
	await get_tree().create_timer(0.5).timeout
	
	var ai = get_node_or_null("AIController2D")
	if ai:
		ai.reward -= 5.0
		ai.done = true
		
		if GameManager.is_ai_mode:
			GameManager.lives -= 1
			GameManager.rings = 0
			if GameManager.lives <= 0:
				GameManager.lives = 3
			is_dead = false
			is_hit = false
			position = Vector2(0, 30)
			velocity = Vector2.ZERO
			set_physics_process(true)
			sprite.play("idle")
			return
	
	GameManager.lives -= 1
	GameManager.rings = 0
	
	if GameManager.lives <= 0:
		GameManager.lives = 3
		var death_screen = preload("res://scenes/ui/DeathScreen.tscn").instantiate()
		get_tree().root.add_child(death_screen)
		await death_screen.show_death(current_level_path)
	else:
		if GameManager.is_ai_mode:
			is_dead = false
			is_hit = false
			position = Vector2(0, 30)
			velocity = Vector2.ZERO
			set_physics_process(true)
			sprite.play("idle")
			GameManager.rings = 0
		else:
			var trans = preload("res://scenes/ui/ZoneTransition.tscn").instantiate()
			get_tree().root.add_child(trans)
			var zone = "PINK ZONE"
			var act = "ACT 1"
			if "Level2" in current_level_path:
				zone = "GREEN ZONE"
				act = "ACT 2"
			elif "Level3" in current_level_path:
				zone = "CYAN ZONE"
				act = "ACT 3"
			GameManager.is_reloading = true
			await trans.show_transition(zone, act)
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
		get_parent().add_child.call_deferred(ring)
		ring.global_position = global_position
		var angle = (i / float(ring_count)) * TAU
		var speed = randf_range(100, 200)
		ring.launch(Vector2(cos(angle), sin(angle)) * speed)

func ai_move(direction: int):
	if direction != 0:
		velocity.x = direction * SPEED
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func ai_jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY

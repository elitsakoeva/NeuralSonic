extends AIController2D

func get_obs() -> Dictionary:
	var player = get_parent()
	

	var space_state = player.get_world_2d().direct_space_state
	var ray_right = PhysicsRayQueryParameters2D.create(
		player.global_position,
		player.global_position + Vector2(100, 0)
	)
	var ray_down = PhysicsRayQueryParameters2D.create(
		player.global_position,
		player.global_position + Vector2(0, 100)
	)
	var result_right = space_state.intersect_ray(ray_right)
	var result_down = space_state.intersect_ray(ray_down)
	
	return {
		"obs": [
			player.position.x / 1000.0,
			player.position.y / 500.0,
			player.velocity.x / 150.0,
			player.velocity.y / 300.0,
			float(player.is_on_floor()),
			float(result_right.size() > 0), 
			float(result_down.size() > 0),
		]
	}

func get_reward() -> float:
	var player = get_parent()
	var r = 0.0

	r += max(player.velocity.x, 0) * 0.1
	
	if player.velocity.x < 0:
		r -= 10.0
	
	if not player.is_on_floor():
		r -= 0.5
	
	if abs(player.velocity.x) < 10:
		r -= 5.0
		
	return r

func get_action_space() -> Dictionary:
	return {
		"move": {
			"size": 2,
			"action_type": "discrete"
		},
		"jump": {
			"size": 2,
			"action_type": "discrete"
		}
	}

func set_action(action) -> void:
	var player = get_parent()
	
	var move = int(action["move"])
	if move == 1:
		player.ai_move(1)
	else:
		player.ai_move(0)
	
	if int(action["jump"]) == 1:
		player.ai_jump()
		
func _physics_process(delta):
	super._physics_process(delta)
	if needs_reset:
		needs_reset = false
		done = true

func _ready():
	if GameManager.is_ai_mode:
		super._ready()
		print("AI Controller ready!")

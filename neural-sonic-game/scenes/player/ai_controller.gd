extends AIController2D

func get_obs() -> Dictionary:
	var player = get_parent()
	
	return {
		"obs": [
			player.position.x / 1000.0,
			player.position.y / 500.0,
			player.velocity.x / 150.0,
			player.velocity.y / 300.0,
			float(player.is_on_floor()),
		]
	}

func get_reward() -> float:
	var player = get_parent()
	var r = 0.0
	
	if player.velocity.x > 0:
		r += 1.0
		
	if player.velocity.x < 0:
		r -= 0.5
		
	if player.velocity.x == 0:
		r -= 0.3
	
	r += GameManager.rings * 0.5
	
	return r

func get_action_space() -> Dictionary:
	return {
		"move": {
			"size": 3,
			"action_type": "discrete"
		},
		"jump": {
			"size": 2,
			"action_type": "discrete"
		}
	}

func set_action(action) -> void:
	print("action received: ", action)
	var player = get_parent()
	
	var move = int(action["move"])
	if move == 1:
		player.ai_move(-1)
	elif move == 2:
		player.ai_move(1)
	else:
		player.ai_move(0)
	if action["jump"] == 1:
		player.ai_jump()

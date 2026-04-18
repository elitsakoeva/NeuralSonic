extends CanvasLayer

@onready var time_label = $TimeLabel

var elapsed_time: float = 0.0
var is_running: bool = true

func _process(delta):
	if not is_running:
		return
	
	elapsed_time += delta
	
	var minutes = int(elapsed_time) / 60
	var seconds = int(elapsed_time) % 60
	
	time_label.text = "TIME: %02d:%02d" % [minutes, seconds]

func stop_timer():
	is_running = false

func reset_timer():
	elapsed_time = 0.0
	is_running = true

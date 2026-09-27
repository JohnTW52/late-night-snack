extends Node3D

var timer := 0.01
var timer_done := false

func _process(delta: float) -> void:
	if not timer_done:
		timer -= delta
		handle_lights()
		print(timer)

func handle_lights() -> void:
	if timer <= 0:
		timer_done = true
		for node in get_children():
			if node is AreaLight3D and node.has_method("toggle_light_loop"):
				await get_tree().create_timer(0.2).timeout
				node.toggle_light_loop()

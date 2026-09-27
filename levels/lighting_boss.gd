extends Node3D

var timer := 0.2

func _process(delta: float) -> void:
	timer -= delta

func setup_lights() -> void:
	if timer <= 0.01:
		for node in get_children():
			if node is AreaLight3D and node.has_method("toggle_light_loop"):
				node.toggle_light_loop()
		timer = 0.2

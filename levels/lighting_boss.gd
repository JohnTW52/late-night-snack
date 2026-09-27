extends Node3D

func _ready() -> void:
	for node in get_children():
		if node is AreaLight3D and node.has_method("toggle_light_loop"):
			await get_tree().create_timer(0.2).timeout
			node.toggle_light_loop()

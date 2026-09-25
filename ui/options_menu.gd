extends CanvasLayer

func _on_menu_button_pressed() -> void:
	await get_tree().physics_frame
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")

func _on_apply_button_pressed() -> void:
	visible = false
	owner.get_node("PauseMenu").visible = true
	owner.get_node("PauseMenu").currently_in_options = false

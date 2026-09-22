extends CanvasLayer

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(GameManager.levels[GameManager.level_index])

func _on_leave_pressed() -> void:
	get_tree().quit()

extends CanvasLayer

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(GameManager.levels[GameManager.level_index])

func _on_leave_pressed() -> void:
	get_tree().quit()

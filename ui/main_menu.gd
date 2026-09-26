extends CanvasLayer

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/rules.tscn")

func _on_leave_pressed() -> void:
	get_tree().quit()

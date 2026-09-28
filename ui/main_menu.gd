extends CanvasLayer

@export var level_select: PackedScene

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GameManager.load_data()
	GameManager.main_track.play()
	if (GameManager.debug_mode):
		$Buttons/VBoxContainer/Button2.text = "Debug Mode : on"

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/rules.tscn")

func _on_leave_pressed() -> void:
	get_tree().quit()

# level select
func _on_button_pressed() -> void:
	var child = level_select.instantiate()
	add_child(child)
	
func _on_button_2_pressed() -> void:
	if (GameManager.debug_mode):
		$Buttons/VBoxContainer/Button2.text = "Debug Mode : off"
		GameManager.debug_mode = false
	else:
		$Buttons/VBoxContainer/Button2.text = "Debug Mode : on"
		GameManager.debug_mode = true
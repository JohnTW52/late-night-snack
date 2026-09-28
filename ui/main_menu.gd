extends CanvasLayer

@export var level_select: PackedScene

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GameManager.load_data()
	GameManager.main_track.play()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/rules.tscn")

func _on_leave_pressed() -> void:
	get_tree().quit()

# level select
func _on_button_pressed() -> void:
	var child = level_select.instantiate()
	add_child(child)
	

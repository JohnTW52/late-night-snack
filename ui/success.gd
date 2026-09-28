extends CanvasLayer

@onready var label := $Label

func _ready() -> void:
	label.text = _get_success_text()
	var i = GameManager.level_index
	if (i == 8):
		GameManager.cheer_audio.play()
		await get_tree().create_timer(7).timeout
		label.text = "or do you..."
		await get_tree().create_timer(4).timeout
		get_tree().change_scene_to_file(GameManager.levels[GameManager.level_index])
	elif (i == 9):
		$yeah.play()
		$purr.play()
		await get_tree().create_timer(6).timeout
		get_tree().change_scene_to_file("res://ui/main_menu.tscn")
	else:
		await get_tree().create_timer(1.5).timeout
		get_tree().change_scene_to_file(GameManager.levels[GameManager.level_index])

func _get_success_text() -> String:
	match GameManager.level_index:
		0:
			return "You aren't suppose to see this..."
		1:
			return "Not enough. Need more snack."
		2:
			return "Still not enough. Need more snack."
		3:
			return "Need more. MORE."
		4:
			return "More more more more more..."
		5:
			return "Mmmm mmm m mM MOOROEEE"
		6:
			return "..."
		7:
			return " "
		8:
			return "You win!"
		9:
			return "ok thats enough snack for tonight"
		10:
			return ""
		_:
			return "Uh oh..."

extends CanvasLayer

@onready var label := $Label

func _ready() -> void:
	label.text = _get_success_text()
	print(GameManager.level_index)
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
			return "No no no. Need MORE."
		4:
			return "More. More. More. More."
		5:
			return "Mmmm mmm m mM MOOROEEE"
		6:
			return "..."
		7:
			return " "
		8:
			return "i don feel so good"
		9:
			return "jus.. one.. more... snack"
		10:
			return "ok thats enough snack for tonight"
		_:
			return "Uh oh..."

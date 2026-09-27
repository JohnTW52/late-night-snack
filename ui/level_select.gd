extends CanvasLayer

func _ready() -> void:
	GameManager.load_data()
	update_colors()
			
func update_colors():
	for b in $GridContainer.get_children():
		var index = b.name.to_int()-1;
		var d = GameManager.level_completion_data[index];
		if (d == 0): # its playable but not completed
			b.disabled = false
			b.modulate = Color.WHITE
		elif (d == 1): # its completed and should be highlighted
			b.disabled = false
			b.modulate = Color.GREEN
		elif (d == -1): # not yet unlocked
			b.disabled = true
			b.modulate = Color.RED

func _on_back_pressed() -> void:
	queue_free()

func _on_1_pressed() -> void:
	_change_level(0)

func _on_2_pressed() -> void:
	_change_level(1)

func _on_3_pressed() -> void:
	_change_level(2)

func _on_4_pressed() -> void:
	_change_level(3)

func _on_secret_pressed() -> void:
	_change_level(-1)
	
func _on_5_pressed() -> void:
	_change_level(4)

func _on_6_pressed() -> void:
	_change_level(5)

func _on_7_pressed() -> void:
	_change_level(6)

func _on_8_pressed() -> void:
	_change_level(7)

func _on_9_pressed() -> void:
	_change_level(8)
	
func _change_level(index):
	if (index == -1):
		get_tree().change_scene_to_file("res://levels/secret_spin_level.tscn")
		# will have to change this if level 4 gets re-ordered
		GameManager.level_index = 3;
	else:
		get_tree().change_scene_to_file(GameManager.levels[index])
		GameManager.sync_level_index()
	queue_free()

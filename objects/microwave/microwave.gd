class_name Microwave extends Node3D
	
func can_interact(_player: PlayerCharacter) -> bool:
	return true

func interact(_player: PlayerCharacter) -> void:
	change_level()

func change_level() -> void:
	if GameManager.has_next_level():
		var next_level := GameManager.levels[GameManager.level_index + 1]
		GameManager.increment_level_index()
		get_tree().change_scene_to_file(next_level)
	else:
		print("Already on last level.")

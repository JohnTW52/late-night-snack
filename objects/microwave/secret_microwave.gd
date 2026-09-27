extends Node3D

func can_interact(_player: PlayerCharacter) -> bool:
	return true

func interact(_player: PlayerCharacter) -> void:
	change_level()

func change_level() -> void:
	get_tree().change_scene_to_file("res://levels/secret_spin_level.tscn")

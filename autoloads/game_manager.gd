extends Node

var just_changed_level := false
var game_over: bool = false
var level_index: int
var timer_vals: Dictionary = {
	1: 10.0,
	2: 30.0
}

@onready var levels: Array[String] = [
	"res://levels/level01.tscn", 
	"res://levels/level02.tscn"
	]

# This function will be useful if we add save and quit later
# Will set level_index to whatever current level is
func sync_level_index() -> void:
	var current_scene := get_tree().current_scene
	
	if current_scene == null:
		return
	
	var scene_path := current_scene.scene_file_path
	var index := levels.find(scene_path)
	if index >= 0:
		level_index = index
	else:
		level_index = 0

func has_next_level() -> bool:
	if levels:
		return level_index + 1 < levels.size()
	
	print("Levels not initialized.")
	return false

func increment_level_index() -> void:
	sync_level_index()
	level_index += 1

func get_timer_val() -> float:
	sync_level_index()
	return timer_vals[level_index + 1]

func on_game_over() -> void:
	get_tree().change_scene_to_file(levels[level_index])
	game_over = false

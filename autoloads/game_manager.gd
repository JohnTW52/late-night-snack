extends Node

var just_changed_level := false
var game_over: bool = false
var level_index: int
var timer_vals: Dictionary = {
	1: 10.0,
	2: 15.0,
	3: 20.0,
	4: 30.0,
	5: 45.0,
	6: 10.0,
	7: 10.0,
	8: 10.0,
	9: 10.0,
	10: 10.0,
	11: 10.0
}

@onready var levels: Array[String] = [
	"res://levels/level01.tscn", 
	"res://levels/level02.tscn",
	"res://levels/level03.tscn",
	"res://levels/level04.tscn",
	"res://levels/level05.tscn",
	"res://levels/level06.tscn",
	"res://levels/level07.tscn",
	"res://levels/level08.tscn",
	"res://levels/level09.tscn",
	"res://levels/level010.tscn",
	"res://levels/level011.tscn"
	]

func _ready() -> void:
	just_changed_level = false

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

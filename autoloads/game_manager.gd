extends Node

var level_index: int

@onready var levels: Array[String] = [
	"res://levels/level01.tscn", 
	"res://levels/level02.tscn"
	]

func _ready() -> void:
	# Autoloads run before nodes are created so this ensure no runtime errors
	call_deferred("sync_level_index")

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
	level_index += 1

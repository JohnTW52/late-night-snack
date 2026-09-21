extends Node

var level_index: int = 0

@onready var levels: Array[String] = [
	"res://levels/level01.tscn", 
	"res://levels/level02.tscn"
	]

func _ready() -> void:
	print("Level index:", level_index)
	print(levels)

func has_next_level() -> bool:
	if levels:
		return level_index + 1 < levels.size()
	
	print("Levels not initialized.")
	return false

func increment_level_index() -> void:
	level_index += 1

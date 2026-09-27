extends Node

var just_changed_level := false
var game_over: bool = false
var level_index: int
var timer_vals: Dictionary = {
	1: 10.0,
	2: 15.0,
	3: 20.0,
	4: 15.0,
	5: 20.0,
	6: 7.0,
	7: 10.0,
	8: 60.0,
	9: 10.0,
	10: 10.0,
	11: 10.0
}

@onready var levels: Array[String] = [
	"res://levels/level01.tscn", 
	"res://levels/level02.tscn",
	"res://levels/level03.tscn",
	"res://levels/level04.tscn",
	"res://levels/secret_spin_level.tscn",
	"res://levels/level05.tscn",
	"res://levels/level06.tscn",
	"res://levels/level07.tscn",
	"res://levels/level08.tscn",
	"res://levels/level09.tscn"
]

func _ready() -> void:
	just_changed_level = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart level"):
		get_tree().reload_current_scene();
		game_over = false
	
	# temp for debugging
	if Input.is_action_just_pressed("1"):
		get_tree().change_scene_to_file(levels[0])
		sync_level_index()
	if Input.is_action_just_pressed("2"):
		get_tree().change_scene_to_file(levels[1])
		sync_level_index()
	if Input.is_action_just_pressed("3"):
		get_tree().change_scene_to_file(levels[2])
		sync_level_index()
	if Input.is_action_just_pressed("4"):
		get_tree().change_scene_to_file(levels[3])
		sync_level_index()
	if Input.is_action_just_pressed("5"):
		get_tree().change_scene_to_file(levels[4])
		sync_level_index()
	if Input.is_action_just_pressed("6"):
		get_tree().change_scene_to_file(levels[5])
		sync_level_index()
	if Input.is_action_just_pressed("7"):
		get_tree().change_scene_to_file(levels[6])
		sync_level_index()
	if Input.is_action_just_pressed("8"):
		get_tree().change_scene_to_file(levels[7])
		sync_level_index()
	if Input.is_action_just_pressed("9"):
		get_tree().change_scene_to_file(levels[8])
		sync_level_index()
	if Input.is_action_just_pressed("0"):
		get_tree().change_scene_to_file(levels[9])
		sync_level_index()

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

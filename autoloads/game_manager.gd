extends Node

var cheer_audio: AudioStreamPlayer
var main_track: AudioStreamPlayer

var just_changed_level := false
var game_over: bool = false
var level_index: int
var timer_vals: Dictionary = {
	1: 10.0,
	2: 15.0,
	3: 10.0,
	4: 15.0,
	5: 10.0,
	6: 15.0,
	7: 55.0,
	8: 30.0,
	9: 60.0,
	10: 10.0
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
	"res://levels/level09.tscn"
]

# index 0 is level 1 and so on
var level_completion_data: Array[int] = [
	0, -1, -1, -1, -1, -1, -1, -1, -1, -1 # last one is secret level
]

var total_fails : int = 0

func _ready() -> void:
	load_data()
	just_changed_level = false
	
	cheer_audio = AudioStreamPlayer.new()
	add_child(cheer_audio)
	cheer_audio.stream = preload("res://sfx/ominous cheers.mp3")
	cheer_audio.volume_db = -12
	
	main_track = AudioStreamPlayer.new()
	add_child(main_track)
	main_track.stream = preload("res://sfx/music/main.mp3")
	main_track.volume_db = -7

func _process(_delta: float) -> void:
	if main_track.playing == false:
		main_track.play()
	elif level_index == 8:
		main_track.stop()
	
	if Input.is_action_just_pressed("restart level"):
		total_fails += 1;
		save_data()
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
	# this will break the secret level setup: sync_level_index()
	level_index += 1

func get_timer_val() -> float:
	sync_level_index()
	return timer_vals[level_index + 1]

func on_game_over() -> void:
	get_tree().change_scene_to_file(levels[level_index])
	total_fails += 1;
	save_data()
	game_over = false

func save_data():
	var file = FileAccess.open("user://level.dat", FileAccess.WRITE)
	file.store_var(level_completion_data)
	var file2 = FileAccess.open("user://fails.dat", FileAccess.WRITE)
	file2.store_var(total_fails)
	
func load_data(): # called when menu loads
	if FileAccess.file_exists("user://level.dat"):
		var file = FileAccess.open("user://level.dat", FileAccess.READ)
		level_completion_data = file.get_var()
	if FileAccess.file_exists("user://fails.dat"):
		var file2 = FileAccess.open("user://fails.dat", FileAccess.READ)
		total_fails = file2.get_var()

# for testing purposes
#func reset_save():
#	var default_lcd : Array[int] = [0,-1,-1,-1,-1,-1,-1,-1,-1,-1]
#	var file = FileAccess.open("user://save.dat", FileAccess.WRITE)
#	file.store_var(default_lcd)

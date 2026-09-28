class_name Microwave extends Node3D

signal microwave_timer_done
signal after_last_chance

var timer_done_not_already_emitted: bool = true;

var timer: float 

@onready var timer_ui := $Timer/MarginContainer/Label
@onready var level_ui := $MarginContainer/Label
@onready var minus_time_ui := $MinusTime
@onready var add_time_ui := $AddTime

func _ready() -> void:
	minus_time_ui.visible = false
	add_time_ui.visible = false
	
	if GameManager.just_changed_level:
		show_success_screen()
	if get_tree() != null and get_tree().current_scene.name == "SecretLevel":
		timer = 30;
		GameManager.level_index = 3;
		GameManager.level_completion_data[9] = 0
		GameManager.save_data()
	else:
		timer = GameManager.get_timer_val()
	
	update_level_ui()

func _process(delta: float) -> void:
	if timer > 0.01:
		tick_timer(delta)
		update_timer_ui(timer)
	elif timer_done_not_already_emitted:
		$hum.stop()
		timer_done_not_already_emitted = false
		microwave_timer_done.emit()

func can_interact(_player: PlayerCharacter) -> bool:
	return true

func interact(_player: PlayerCharacter) -> void:
	change_level()

func change_level() -> void:
	GameManager.just_changed_level = true
	if get_tree() != null and get_tree().current_scene.name == "SecretLevel":
		GameManager.level_completion_data[9] = 1
	else:
		GameManager.level_completion_data[GameManager.level_index] = 1
	GameManager.level_completion_data[GameManager.level_index+1] = 0
	GameManager.save_data()
	
	if GameManager.has_next_level():
		var next_level := GameManager.levels[GameManager.level_index + 1]
		GameManager.increment_level_index()
		get_tree().change_scene_to_file(next_level)
	else:
		GameManager.increment_level_index()
		await get_tree().create_timer(4).timeout
		GameManager.main_track.stop()
		show_success_screen()

func tick_timer(delta: float) -> void:
	timer -= delta

func add_time(amt: float) -> void:
	timer += amt

func remove_time(amt: float) -> void:
	timer -= amt

func update_timer_ui(time: float) -> void:
	timer_ui.text = "%d" % int(time)

func update_level_ui() -> void:
	if get_tree() != null and get_tree().current_scene.name == "SecretLevel":
		level_ui.text = "???/"
		return
	level_ui.text = "%d/9" % (GameManager.level_index + 1)

func show_success_screen() -> void:
	get_tree().change_scene_to_file("res://ui/success.tscn")
	GameManager.just_changed_level = false

func toggle_minus_time(time: float) -> void:
	minus_time_ui.visible = true
	minus_time_ui.get_node("Label").text = "- %d" % time
	await get_tree().create_timer(1.0).timeout
	minus_time_ui.visible = false

func toggle_add_time(time: float) -> void:
	add_time_ui.visible = true
	add_time_ui.get_node("Label").text = "- %.1f" % time
	await get_tree().create_timer(1.0).timeout
	add_time_ui.visible = false

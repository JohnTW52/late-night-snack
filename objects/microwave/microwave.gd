class_name Microwave extends Node3D

signal microwave_timer_done
signal after_last_chance

var timer_done_not_already_emitted: bool = true;

var timer: float 

@onready var timer_ui := $Timer/MarginContainer/Label
@onready var success_ui := $Success

func _ready() -> void:
	if GameManager.just_changed_level:
		show_success_screen()
	
	timer = GameManager.get_timer_val()

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
	
	if GameManager.has_next_level():
		var next_level := GameManager.levels[GameManager.level_index + 1]
		GameManager.increment_level_index()
		get_tree().change_scene_to_file(next_level)
	else:
		print("Already on last level.")

func tick_timer(delta: float) -> void:
	timer -= delta

func add_time(amt: float) -> void:
	timer += amt

func update_timer_ui(time: float) -> void:
	timer_ui.text = "%d" % int(time)

func show_success_screen() -> void:
	success_ui.show()
	await get_tree().create_timer(1.5).timeout
	success_ui.hide()
	
	GameManager.just_changed_level = false

class_name Microwave extends Node3D

signal microwave_timer_done

var timer: float 

@onready var timer_ui := $Timer/MarginContainer/Label

func _ready() -> void:
	timer = GameManager.get_timer_val()

func _process(delta: float) -> void:
	if timer > 0.01:
		tick_timer(delta)
		update_timer_ui(timer)
	else:
		microwave_timer_done.emit()

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

func tick_timer(delta: float) -> void:
	timer -= delta

func update_timer_ui(time: float) -> void:
	timer_ui.text = "%d" % int(time)

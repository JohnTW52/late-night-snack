extends CanvasLayer

@onready var _continue_label := $Label3

func _ready() -> void:
	_continue_label.visible = false
	await get_tree().create_timer(3.0).timeout
	var tween = create_tween().set_loops()
	tween.tween_callback(_continue_label.hide).set_delay(0.5)
	tween.tween_callback(_continue_label.show).set_delay(0.5)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("play_char_interact"):
		get_tree().change_scene_to_file("res://levels/level01.tscn")

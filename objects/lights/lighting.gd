extends Node3D

var microwave: Microwave

func _ready() -> void:
	show()
	microwave = get_parent().get_node("Microwave")
	microwave.microwave_timer_done.connect(_on_microwave_timer_done)

func _on_microwave_timer_done() -> void:
	hide()

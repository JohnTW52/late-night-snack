extends Node3D

var microwave: Microwave

func _ready() -> void:
	show()
	microwave = owner.get_node("Microwave")
	if microwave:
		microwave.microwave_timer_done.connect(_on_microwave_timer_done)
	elif microwave == null:
		print("Could not find microwave in scene tree")

func _on_microwave_timer_done() -> void:
	hide()

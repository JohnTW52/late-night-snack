class_name SpinComponent extends Node3D

@export var _rotation_speed := 2.0

var _not_ready: bool

func _ready() -> void:
	if get_parent().name != "AnimatableBody3D":
		_not_ready = true
	else:
		_not_ready = false

func _process(delta: float) -> void:
	if _not_ready:
		print("Couldn't find AnimatableBody3D parent object.")
	else:
		get_parent().global_rotate(Vector3.UP, _rotation_speed * delta)

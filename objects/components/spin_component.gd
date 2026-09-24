class_name SpinComponent extends Node3D

@export var _rotation_speed := 2.0

func _process(delta: float) -> void:
	owner.rotate(Vector3.UP, _rotation_speed * delta)

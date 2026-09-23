class_name SpinComponent extends Node3D

@export var _rotation_speed := 3.0

func _process(delta: float) -> void:
	owner.get_node("AnimatableBody3D").rotate(Vector3.FORWARD, _rotation_speed * delta)

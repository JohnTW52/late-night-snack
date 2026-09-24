class_name MoveComponent extends Node3D

@export var move_duration := 2.0
var _root: Node3D
var markers: Array[Marker3D] = []

func _ready() -> void:
	_set_root()

func _set_root() -> void:
	_root = owner.get_node("AnimatableBody3D")

	if _root == null:
		print("Could not find AnimatableBody3D node")
		return

	for node in owner.get_children():
		if node is Marker3D:
			markers.append(node)
	
	if markers:
		_start_movement()
	else:
		print("Could not find position markers")

func _start_movement() -> void:
	# might need to make this more accessable to call tween.pause() or something
	var tween := create_tween()
	tween.set_loops()

	tween.tween_property(_root, "global_position", markers[0].global_position, move_duration)
	tween.tween_property(_root, "global_position", markers[1].global_position, move_duration)

@tool
extends Node3D

@export var move_duration := 4.0:
	set(value):
		move_duration = value
		$MoveComponent.move_duration = value

@export var point_1_location = Vector3(0, 0, 2.875):
	set(value):
		point_1_location = value
		$PointA.position = value

@export var point_2_location = Vector3(0, 0, -2.875):
	set(value):
		point_2_location = value;
		$PointB.position = value;

func _ready() -> void:
	$MoveComponent.move_duration = move_duration;
	$PointA.position = point_1_location
	$PointB.position = point_2_location

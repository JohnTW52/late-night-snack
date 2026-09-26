extends Node3D

@export var time_to_remove := 7.0

@onready var audio := $AudioStreamPlayer3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is PlayerCharacter:
		owner.get_node("Microwave").remove_time(time_to_remove)
		audio.play()

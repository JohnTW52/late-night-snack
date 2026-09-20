extends State
class_name SatState

var state_name: String = "Sat"
var play_char: CharacterBody3D

func enter(play_char_ref: CharacterBody3D) -> void:
	play_char = play_char_ref
	play_char.velocity = Vector3.ZERO
	play_char.input_direction = Vector2.ZERO

func physics_update(_delta: float) -> void:
	play_char.velocity = Vector3.ZERO
	play_char.input_direction = Vector2.ZERO
	
	var bus := play_char.get_parent().get_parent()
	var bus_is_moving = bus != null and bus.has_method("is_driving") and bus.is_driving()
	
	if Input.is_action_just_pressed(play_char.unsit_action) and not bus_is_moving:
		play_char.unsit()

func update(_delta: float) -> void:
	pass 

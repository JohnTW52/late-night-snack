class_name State
extends Node

signal transitioned(new_state: State)

func enter(_char_reference: CharacterBody3D):
	# Enter state
	pass
	
func exit():
	# Exit state
	pass
	
func update(_delta: float):
	# Process update
	pass
	
func physics_update(_delta: float):
	# Physics_process update
	pass 

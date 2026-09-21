class_name StateMachine extends Node

signal change_fov
signal change_cam_position

@export var initial_state : State

var curr_state: State
var curr_state_name: String
var prev_state: State
var prev_state_name: String
var states : Dictionary = {}

@onready var play_char : CharacterBody3D = $".."

func _ready() -> void:
	# Get all the state childrens
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_state_child_transition)
			
	# If initial state, transition to it
	if initial_state:
		initial_state.enter(play_char)
		curr_state = initial_state
		curr_state_name = curr_state.state_name
		
func _process(delta: float) -> void:
	if GameManager.game_over:
		return
	
	if curr_state: curr_state.update(delta)
	
func _physics_process(delta: float) -> void:
	if GameManager.game_over:
		return
	
	if play_char.movement_locked:
		play_char.velocity = Vector3.ZERO
		return
	if curr_state:
		curr_state.physics_update(delta)
	
func on_state_child_transition(state: State, new_state_name: String) -> void:
	# Manage the transition from one state to another
	
	if state != curr_state: return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state: return
	
	# Exit the current state
	if curr_state: curr_state.exit()
	
	# Track previous state
	prev_state = curr_state
	prev_state_name = curr_state_name
	
	# Enter the new state
	new_state.enter(play_char)
	
	curr_state = new_state
	curr_state_name = curr_state.state_name
	
	change_cam_position.emit()
	change_fov.emit()

func transition_to(new_state_name: String) -> void:
	var new_state = states.get(new_state_name.to_lower())
	if !new_state or new_state == curr_state:
		return
	
	if curr_state:
		curr_state.exit()
	
	# Track previous state
	prev_state = curr_state
	prev_state_name = curr_state_name
	
	new_state.enter(play_char)
	curr_state = new_state
	curr_state_name = curr_state.state_name
	
	change_cam_position.emit()
	change_fov.emit()

extends Node2D

var currently_paused := false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("pause") and not currently_paused):
		visible = true
		currently_paused = true;
		for node in get_tree().get_nodes_in_group("pause me"):
			node.set_process(false)
			node.set_process_input(false)
			node.set_process_internal(false)
			node.set_physics_process(false)		
		
	elif (Input.is_action_just_pressed("pause") and currently_paused):
		visible = false
		currently_paused = false;
		for node in get_tree().get_nodes_in_group("pause me"):
			node.set_process(true)
			node.set_process_input(true)
			node.set_process_internal(true)
			node.set_physics_process(true)

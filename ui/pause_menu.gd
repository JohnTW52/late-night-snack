extends CanvasLayer

var currently_paused := false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("play_char_pause") and not currently_paused):
		_pause_game()
	elif (Input.is_action_just_pressed("play_char_pause") and currently_paused):
		_resume_game()

func _on_button_pressed() -> void:
	_resume_game()

func _pause_game() -> void:
	visible = true
	currently_paused = true;
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for node in get_tree().get_nodes_in_group("pause me"):
		if node is Timer:
			node.paused = true
		elif node is AudioStreamPlayer3D:
			node.stream_paused = true
		else:
			node.set_process(false)
			node.set_process_input(false)
			node.set_process_internal(false)
			node.set_physics_process(false)
			node.set_process_unhandled_input(false)
		

func _resume_game() -> void:
	visible = false
	currently_paused = false;
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	for node in get_tree().get_nodes_in_group("pause me"):
		if node is Timer:
			node.paused = false
		elif node is AudioStreamPlayer3D:
			node.stream_paused = false
		else:
			node.set_process(true)
			node.set_process_input(true)
			node.set_process_internal(true)
			node.set_physics_process(true)
			node.set_process_unhandled_input(true)


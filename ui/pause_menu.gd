extends CanvasLayer

@export var level_select: PackedScene

var currently_paused := false
var currently_in_options := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("play_char_pause") and not currently_paused):
		_pause_game()
	elif (Input.is_action_just_pressed("play_char_pause") and currently_paused and not currently_in_options):
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
		elif node is AudioStreamPlayer3D or node is AudioStreamPlayer:
			node.stream_paused = true
		else:
			node.set_process(false)
			node.set_process_input(false)
			node.set_process_internal(false)
			node.set_physics_process(false)
			node.set_process_unhandled_input(false)

func _resume_game() -> void:
	# if level select is open
	for c in get_children():
		if (c.name == "LevelSelect"):
			c.queue_free()

	visible = false
	currently_paused = false;
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	for node in get_tree().get_nodes_in_group("pause me"):
		if node is Timer:
			node.paused = false
		elif node is AudioStreamPlayer3D or node is AudioStreamPlayer:
			node.stream_paused = false
		else:
			node.set_process(true)
			node.set_process_input(true)
			node.set_process_internal(true)
			node.set_physics_process(true)
			node.set_process_unhandled_input(true)

func _on_options_button_pressed() -> void:
	currently_in_options = true
	visible = false
	owner.get_node("OptionsMenu").visible = true

func _on_menu_button_pressed() -> void:
	await get_tree().physics_frame
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")

# teehee
func _on_exit_button_pressed() -> void:
	var index = randi_range(0, 3);
	var current_index = $VBoxContainer/Button4.get_index();
	while index == current_index:
		index = randi_range(0, 3);
	$VBoxContainer.move_child($VBoxContainer/Button4, index)

func _on_button_2_pressed() -> void:
	var child = level_select.instantiate()
	add_child(child)
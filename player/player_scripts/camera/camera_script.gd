class_name CameraObject extends Node3D

# -------------------------------------------------------------------------
# Camera variables
# -------------------------------------------------------------------------

@export_group("Camera variables")
@export_range(0.0, 0.5, 0.001) var x_axis_sensibility: float = 0.05
@export_range(0.0, 0.5, 0.001) var y_axis_sensibility: float = 0.05
@export_range(-360.0, 0.0, 0.01) var max_up_angle_view: float = -90.0 # In degrees.
@export_range(0.0, 360.0, 0.01) var max_down_angle_view: float = 90.0 # In degrees.
@export_range(5.0, 175.0, 0.01) var fov: float = 90.0

# -------------------------------------------------------------------------
# Position variables
# -------------------------------------------------------------------------

@export_group("Position variables")
# Keys are state names. Vector2.x = camera Y position, Vector2.y = tween duration.
@export var cam_position_per_state: Dictionary[String, Vector2] = {
	"Idle": Vector2(0.55, 0.15),
	"Crouch": Vector2(0.35, 0.15),
	"Walk": Vector2(0.55, 0.15),
	"Run": Vector2(0.55, 0.15),
	"Jump": Vector2(0.55, 0.15),
	"Inair": Vector2(0.55, 0.15),
	"Sat": Vector2(0.55, 0.15),
}

var pos_tween: Tween

# -------------------------------------------------------------------------
# FOV variables
# -------------------------------------------------------------------------

@export_group("FOV variables")
@export_range(0.0, 180.0, 0.01) var min_fov_val: float = 10.0
@export_range(0.0, 180.0, 0.01) var max_fov_val: float = 170.0
# Keys are state names. Vector2.x = target FOV, Vector2.y = tween duration.
@export var cam_fov_per_state: Dictionary[String, Vector2] = {
	"Default": Vector2(90.0, 0.2),
	"Idle": Vector2(90.0, 0.2),
	"Crouch": Vector2(90.0, 0.2),
	"Walk": Vector2(90.0, 0.2),
	"Run": Vector2(100.0, 0.2),
	"Sat": Vector2(90.0, 0.2)
}

var fov_tween: Tween

# -------------------------------------------------------------------------
# Zoom variables
# -------------------------------------------------------------------------

@export_group("Zoom variables")
@export_range(-180.0, 180.0, 1.0) var zoom_val: float = 40.0
@export_range(0.0, 3.0, 0.01) var zoom_duration: float = 0.2

var zoom_on: bool = false
var zoom_has_occured: bool = false

# -------------------------------------------------------------------------
# Tilt variables
# -------------------------------------------------------------------------

@export_group("Tilt variables")
@export var enable_forward_tilt: bool = true
@export var enable_side_tilt: bool = true
@export_range(0.0, 400.0, 0.1) var forward_move_tilt_divider: float = 260.0
@export_range(0.0, 7.0, 0.01) var forward_move_tilt_duration: float = 0.19
@export_range(0.0, 2.0, 0.001) var forward_move_max_tilt_val: float = 2.0
@export_range(0.0, 6.0, 0.1) var side_move_tilt_divider: float = 2.8
@export_range(0.0, 24.0, 0.01) var side_move_tilt_speed: float = 10.0
@export_range(0.0, 12.0, 0.001) var side_move_max_tilt_val: float = 7.0
# Keys are state names. Vector2.x = lean value (radians), Vector2.y = lerp speed.
@export var tilt_props_per_state: Dictionary[String, Vector2] = {
	"Default": Vector2(0.0, 7.5),
	"Idle": Vector2(0.0, 7.5),
	"Crouch": Vector2(5.0, 7.5),
	"Walk": Vector2(0.0, 7.5),
	"Run": Vector2(0.0, 7.5),
	"Sat": Vector2(5.0, 7.5)
}

var tilt_tween: Tween
var last_input_y: float

# -------------------------------------------------------------------------
# Bob variables
# -------------------------------------------------------------------------

# Headbob parameters are uniform across all states.
@export_group("Bob variables")
@export var enable_headbob: bool = true
@export_range(0.0, 0.15, 0.001) var bob_pitch: float = 0.05 ## In degrees.
@export_range(0.0, 0.15, 0.001) var bob_roll: float = 0.025 ## In degrees.
@export_range(0.0, 1000.0, 1.0) var bob_height_divider: float = 550.0
@export_range(2.0, 10.0, 0.1) var bob_frequency: float = 7.0
@export_range(0.0, 1.0, 0.001) var cam_max_v_offset: float = 0.3
@export_range(0.0, 15.0, 0.1) var cam_v_offset_to_0_speed: float = 1.0

var step_timer: float = 0.0

# -------------------------------------------------------------------------
# Mouse variables
# -------------------------------------------------------------------------

@export_group("Mouse variables")
var mouse_free: bool = false

# -------------------------------------------------------------------------
# Keybind variables
# -------------------------------------------------------------------------

@export_group("Keybind variables")
@export var zoom_action: StringName = "play_char_zoom_action"
@export var mouse_mode_action: StringName = "play_char_mouse_mode_action"
@export var check_on_ready_if_inputs_registered: bool = true

var default_input_actions: Dictionary
var _input_actions_list: Array[StringName]

# -------------------------------------------------------------------------
# Node references
# -------------------------------------------------------------------------

@onready var camera: Camera3D = %Camera
@onready var play_char: PlayerCharacter = $".."
@onready var state_machine: StateMachine = %StateMachine
@onready var hud: CanvasLayer = %HUD

# -------------------------------------------------------------------------
# State
# -------------------------------------------------------------------------

var state: String

# =========================================================================
# Engine callbacks
# =========================================================================

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.fov = fov
	state = state_machine.curr_state_name

	state_machine.change_cam_position.connect(_get_current_state)
	state_machine.change_cam_position.connect(change_cam_position)
	state_machine.change_fov.connect(change_fov)

	_input_actions_list = [zoom_action, mouse_mode_action]
	_build_default_keybinding()
	_input_actions_check()


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		return
	
	if mouse_free:
		return
	
	var motion := event as InputEventMouseMotion
	play_char.rotate_y(-motion.relative.x * (x_axis_sensibility / 10.0))
	camera.rotate_x(-motion.relative.y * (y_axis_sensibility / 10.0))
	
	# Clamp uses radians because rotation.x is in radians.
	camera.rotation.x = clamp(
		camera.rotation.x,
		deg_to_rad(max_up_angle_view),
		deg_to_rad(max_down_angle_view),
	)

func _process(delta: float) -> void:
	_tilt(delta)
	_bob(delta)
	_zoom()
	_mouse_mode()

# =========================================================================
# Camera state reactions
# =========================================================================

func _get_current_state() -> void:
	state = state_machine.curr_state_name

func change_cam_position() -> void:
	if pos_tween and pos_tween.is_running():
		pos_tween.kill()
	pos_tween = create_tween()
	pos_tween.tween_property(
		self,
		"position:y",
		cam_position_per_state[state][0],
		cam_position_per_state[state][1],
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func change_fov() -> void:
	# If a zoom is already locked in, do not override it with a state-based FOV change.
	if zoom_has_occured:
		return

	camera.fov = clamp(camera.fov, min_fov_val, max_fov_val)

	if not zoom_on and not zoom_has_occured:
		if state != null and state != "Jump" and state != "Inair":
			if fov_tween and fov_tween.is_running():
				fov_tween.kill()
			fov_tween = create_tween()
			fov_tween.tween_property(
				camera,
				"fov",
				cam_fov_per_state[state][0],
				cam_fov_per_state[state][1],
			)

	# Apply zoom regardless of current state; lock it so state changes don't cancel it.
	if zoom_on and not zoom_has_occured:
		zoom_has_occured = true
		if fov_tween and fov_tween.is_running():
			fov_tween.kill()
		fov_tween = create_tween()
		fov_tween.tween_property(camera, "fov", camera.fov - zoom_val, zoom_duration)

# =========================================================================
# Tilt
# =========================================================================

func _tilt(delta: float) -> void:
	if enable_forward_tilt:
		# Forward/backward tilt is a one-shot effect,
		# so a tween is used instead of a lerp.
		var has_started_moving_forward: bool = (
			sign(play_char.input_direction.y) == 1
			and sign(last_input_y) != 1
		)
		var has_started_moving_backward: bool = (
			sign(play_char.input_direction.y) == -1
			and sign(last_input_y) != -1
		)

		if has_started_moving_forward or has_started_moving_backward:
			if tilt_tween and tilt_tween.is_running():
				tilt_tween.kill()
			tilt_tween = create_tween()

			var cam_x_rot_pre_tween: float = rotation.x
			var tilt_offset: float = clamp(
				(-play_char.input_direction.y * play_char.move_speed) / forward_move_tilt_divider,
				-forward_move_max_tilt_val,
				forward_move_max_tilt_val,
			)
			var tilt_target: float = clamp(
				cam_x_rot_pre_tween - tilt_offset,
				deg_to_rad(max_up_angle_view),
				deg_to_rad(max_down_angle_view),
			)

			(tilt_tween
				.tween_property(self, "rotation:x", tilt_target, forward_move_tilt_duration)
				.set_trans(Tween.TRANS_SINE)
				.set_ease(Tween.EASE_OUT))
			(tilt_tween
				.tween_property(self, "rotation:x", cam_x_rot_pre_tween, forward_move_tilt_duration)
				.set_trans(Tween.TRANS_SINE)
				.set_ease(Tween.EASE_IN))

		last_input_y = play_char.input_direction.y

	if enable_side_tilt:
		# Side tilt is continuous, so a lerp is appropriate here.
		rotation_degrees.z = lerp(
			rotation_degrees.z,
			clamp(
				(-play_char.input_direction.x * play_char.move_speed) / side_move_tilt_divider,
				-side_move_max_tilt_val,
				side_move_max_tilt_val,
			),
			side_move_tilt_speed * delta,
		)

# =========================================================================
# Headbob
# =========================================================================

func _bob(delta: float) -> void:
	var bob_speed: float = Vector2(play_char.velocity.x, play_char.velocity.z).length()

	if bob_speed > 0.1:
		step_timer += delta * (bob_speed / bob_frequency)
		# fmod keeps the timer cycling between 0.0 and 1.0 for each step.
		step_timer = fmod(step_timer, 1.0)
	else:
		step_timer = 0.0

	var bob_sinus: float = sin(step_timer * 2.0 * PI) * 0.5
	var is_bobbing_state: bool = state != "Idle" and state != "Jump"
	var ceiling_clear: bool = not play_char.ceiling_check.is_colliding()

	if enable_headbob and is_bobbing_state and ceiling_clear:
		var pitch_delta: float = bob_sinus * deg_to_rad(bob_pitch) * bob_speed
		rotation_degrees.x = clamp(
			rotation_degrees.x - pitch_delta,
			max_up_angle_view,
			max_down_angle_view,
		)

		var roll_delta: float = bob_sinus * deg_to_rad(bob_roll) * bob_speed
		rotation_degrees.z = clamp(
			rotation_degrees.z - roll_delta,
			max_up_angle_view,
			max_down_angle_view,
		)

		camera.v_offset = clamp(camera.v_offset + (bob_sinus * bob_speed) / bob_height_divider, 0.0, cam_max_v_offset)

	elif enable_headbob and (not is_bobbing_state or not ceiling_clear):
		# Smoothly reset the vertical offset when idle, jumping, or under a ceiling
		# to avoid the camera sitting above the character's body.
		if camera.v_offset != 0.0:
			camera.v_offset = move_toward(camera.v_offset, 0.0, cam_v_offset_to_0_speed * delta)

# =========================================================================
# Zoom
# =========================================================================

func _zoom() -> void:
	if not Input.is_action_just_pressed(zoom_action):
		return
	zoom_on = not zoom_on
	if not zoom_on:
		zoom_has_occured = false
	change_fov()

# =========================================================================
# Mouse mode
# =========================================================================

func _mouse_mode() -> void:
	if Input.is_action_just_pressed(mouse_mode_action):
		mouse_free = not mouse_free
	if not mouse_free:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# =========================================================================
# Input map helpers
# =========================================================================

func _build_default_keybinding() -> void:
	# Built at runtime so that export variable overrides are already applied.
	default_input_actions = {
		zoom_action: [Key.KEY_Z] as Array[Key],
		mouse_mode_action: [Key.KEY_ESCAPE] as Array[Key],
	}


func _input_actions_check() -> void:
	# Verifies that every action name is registered in the InputMap.
	# Missing actions are added at runtime with default keybindings and a warning.
	if not check_on_ready_if_inputs_registered:
		return

	var registered_actions: Array[StringName] = []
	for action: StringName in InputMap.get_actions():
		if action.begins_with(&"play_char_"):
			registered_actions.append(action)

	for action: StringName in _input_actions_list:
		assert(action != &"", "There's an undefined input action.")

		if registered_actions.has(action):
			continue

		var key_names: Array = default_input_actions[action].map(
			func(key: Key) -> String: return OS.get_keycode_string(key)
		)

		push_warning(
			"'{input}' missing in InputMap, or input action wrongly named in the editor.\n"
			+ "Adding '{input}' to runtime InputMap temporarily with key/s: {keys}".format(
				{"input": action, "keys": ", ".join(key_names)}
			)
		)

		InputMap.add_action(action)
		for keycode: Key in default_input_actions[action]:
			var event_key := InputEventKey.new()
			event_key.physical_keycode = keycode
			InputMap.action_add_event(action, event_key)

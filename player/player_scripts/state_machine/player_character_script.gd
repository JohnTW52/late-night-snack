class_name PlayerCharacter extends CharacterBody3D

# -------------------------------------------------------------------------
# Movement variables
# -------------------------------------------------------------------------

@export_group("Movement variables")
@export var desired_move_speed_curve: Curve ## Accumulated speed curve.
@export var max_desired_move_speed: float = 30.0
@export var in_air_move_speed_curve: Curve
@export var hit_ground_cooldown: float = 0.1 ## Time the character keeps accumulated speed on landing.
@export var bunny_hop_dms_incre: float = 3.0 ## Bunny-hop desired-move-speed incrementer.
@export var auto_bunny_hop: bool = false
@export var base_hitbox_height: float = 2.0
@export var base_model_height: float = 1.0
@export var height_change_duration: float = 0.15

var move_speed: float
var move_accel: float
var move_deccel: float
var input_direction: Vector2
var move_direction: Vector3
var desired_move_speed: float
var last_frame_position: Vector3
var last_frame_velocity: Vector3
var was_on_floor: bool
var is_falling: bool = false
var movement_locked: bool
var walk_or_run: String = "WalkState" ## Remembers whether the player was walking or running before going airborne.

var hit_ground_cooldown_ref: float

# -------------------------------------------------------------------------
# Crouch variables
# -------------------------------------------------------------------------

@export_group("Crouch variables")
@export var can_crouch: bool = false ## Determines whether the player has the ability to crouch.
@export var continuous_crouch: bool = false ## When true, crouching does not require holding the button.
@export var crouch_speed: float = 6.0
@export var crouch_accel: float = 12.0
@export var crouch_deccel: float = 11.0
@export var crouch_hitbox_height: float = 1.2
@export var crouch_model_height: float = 0.6

# -------------------------------------------------------------------------
# Walk variables
# -------------------------------------------------------------------------

@export_group("Walk variables")
@export var walk_speed: float = 9.0
@export var walk_accel: float = 11.0
@export var walk_deccel: float = 10.0

# -------------------------------------------------------------------------
# Run / stamina variables
# -------------------------------------------------------------------------

@export_group("Run variables")
@export var can_run: bool = true
@export var continuous_run: bool = false ## When true, running does not require holding the button.
@export var use_stamina: bool = true
@export var max_stamina: float = 8.0
@export var stamina_drain_rate: float = 1.0 # max_stamina / drain_rate = sprint duration.
@export var stamina_regen_rate: float = 1.5
@export var stamina_regen_delay: float = 1.0
@export var stamina_cooldown: float = 3.0
@export var run_speed: float = 12.0
@export var run_accel: float = 10.0
@export var run_deccel: float = 9.0

var is_running: bool
var stamina_exhausted: bool = false
var current_stamina: float
var stamina_cooldown_timer: float
var stamina_regen_delay_timer: float = 0.0
var was_running: bool = false

var _was_bar_visible: bool = true
var _fade_tween: Tween
var _flash_tween: Tween
var _draining_stamina: bool = false

# -------------------------------------------------------------------------
# Jump variables
# -------------------------------------------------------------------------

@export_group("Jump variables")
@export var can_jump: bool = true
@export var jump_time_to_peak: float = 0.3
var jump_time_to_fall: float = 0.3
@export var jump_cooldown: float = 0.25
@export var nb_jumps_in_air_allowed: int = 1
@export var coyote_jump_cooldown: float = 0.3

var jump_height: float = 1.3
var jump_cooldown_ref: float
var nb_jumps_in_air_allowed_ref: int
var jump_buff_on: bool = false
var buffered_jump: bool = false
var coyote_jump_cooldown_ref: float
var coyote_jump_on: bool = false

# -------------------------------------------------------------------------
# Gravity variables
# -------------------------------------------------------------------------

@export_group("Gravity variables")
# jump_velocity, jump_gravity, and fall_gravity are computed in _ready()
# because they depend on exported values that may be changed in the editor.
var jump_velocity: float
var jump_gravity: float
var fall_gravity: float

# -------------------------------------------------------------------------
# Keybind variables
# -------------------------------------------------------------------------

@export_group("Keybind variables")
@export var move_forward_action: StringName = "play_char_move_forward_action"
@export var move_backward_action: StringName = "play_char_move_backward_action"
@export var move_left_action: StringName = "play_char_move_left_action"
@export var move_right_action: StringName = "play_char_move_right_action"
@export var run_action: StringName = "play_char_run_action"
@export var crouch_action: StringName = "play_char_crouch_action"
@export var jump_action: StringName = "play_char_jump_action"
@export var interact_action: StringName = "play_char_interact"
@export var unsit_action: StringName = "play_char_unsit"
@export var check_on_ready_if_inputs_registered: bool = true

var default_input_actions: Dictionary
var _input_actions_list: Array[StringName]

# -------------------------------------------------------------------------
# Interact variables
# -------------------------------------------------------------------------

var focused_target: Node = null 
var strength := 70.0
var _currently_interacting: bool = false

# -------------------------------------------------------------------------
# Helper variables
# -------------------------------------------------------------------------

const CEILING_CLEARANCE := 0.2

# -------------------------------------------------------------------------
# Node references
# -------------------------------------------------------------------------

@onready var cam_holder: Node3D = %CameraHolder
@onready var hold_point: Marker3D = $HoldPoint
@onready var cam: Camera3D = %Camera
@onready var model: MeshInstance3D = %Model
@onready var hitbox: CollisionShape3D = %Hitbox
@onready var state_machine: StateMachine = %StateMachine
@onready var hud: CanvasLayer = %HUD
@onready var ceiling_check: RayCast3D = %CeilingCheck
@onready var floor_check: RayCast3D = %FloorCheck
@onready var interact_check: RayCast3D = %InteractCheck
@onready var stamina_bar: TextureProgressBar = $HUD/StaminaBar
@onready var dot_normal: TextureRect = $HUD/Crosshair/DotNormal
@onready var dot_interact: TextureRect = $HUD/Crosshair/DotInteract
@onready var interact_helper_ui: Sprite2D = $HUD/Crosshair/MouseLeftOutline

# =========================================================================
# Engine callbacks
# =========================================================================

func _ready() -> void:
	add_to_group("player")
	# Derived physics constants
	#jump_velocity = (2.0 * jump_height) / jump_time_to_peak
	#jump_gravity = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
	#fall_gravity = (-2.0 * jump_height) / (jump_time_to_fall * jump_time_to_fall)
	
	hit_ground_cooldown_ref = hit_ground_cooldown
	jump_cooldown_ref = jump_cooldown
	jump_cooldown = 0.0
	nb_jumps_in_air_allowed_ref = nb_jumps_in_air_allowed
	coyote_jump_cooldown_ref = coyote_jump_cooldown
	current_stamina = max_stamina
	stamina_cooldown_timer = 0.0
	can_run = true

	stamina_bar.max_value = max_stamina

	_input_actions_list = [
		move_forward_action, move_backward_action,
		move_left_action, move_right_action,
		run_action, crouch_action, jump_action, interact_action,
	]

	_build_default_keybinding()
	_input_actions_check()


func _process(_delta: float) -> void:
	if GameManager.game_over:
		return
	
	if GameManager.just_changed_level:
		hud.hide()
	elif not GameManager.just_changed_level:
		hud.show()
	
	stamina_bar.value = current_stamina
	focused_target = _find_interact_target_from_ray()
	_try_interact()
	_update_flash_tween()
	
	jump_gravity = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
	fall_gravity = (-2.0 * jump_height) / (jump_time_to_fall * jump_time_to_fall)
	jump_velocity = (2.0 * jump_height) / jump_time_to_peak
	

func _physics_process(delta: float) -> void:
	if movement_locked or GameManager.game_over:
		velocity = Vector3.ZERO
		return
	
	is_running = state_machine.curr_state_name == "Run"

	if (was_running and not is_running) or was_on_floor:
		if current_stamina > 0.0 and current_stamina < max_stamina:
			if current_stamina <= max_stamina * 0.3:
				stamina_regen_delay_timer = stamina_regen_delay * 2.0
			else:
				stamina_regen_delay_timer = stamina_regen_delay

	was_running = is_running
	
	if is_on_floor():
		var platform_ang_vel = get_platform_angular_velocity()
		
		if platform_ang_vel.y != 0:
			rotate_y(platform_ang_vel.y * delta)

	_tick_jump_cooldown(delta)
	_modify_physics_properties()
	_tick_stamina(delta)
	move_and_slide()

# =========================================================================
# Movement helpers
# =========================================================================

func _tick_jump_cooldown(delta: float) -> void:
	if jump_cooldown > 0.0:
		jump_cooldown = max(jump_cooldown - delta, 0.0)


func _modify_physics_properties() -> void:
	last_frame_position = global_position
	last_frame_velocity = velocity
	was_on_floor = not is_on_floor()

func gravity_apply(delta: float) -> void:
	## Applies jump gravity while rising and fall gravity while descending.
	if is_on_floor():
		return
	if velocity.y >= 0.0:
		velocity.y += jump_gravity * delta
	else:
		velocity.y += fall_gravity * delta


func resolve_move_state() -> String:
	## Returns the appropriate movement state name based on stamina and intent.
	if walk_or_run == "RunState" and can_run and current_stamina > 0.0:
		return "RunState"
	return "WalkState"

func lock_movement() -> void:
	movement_locked = true
	velocity = Vector3.ZERO
	input_direction = Vector2.ZERO

func unlock_movement() -> void:
	movement_locked = false

# =========================================================================
# Hitbox / model height tweening
# =========================================================================

func tween_hitbox_height(state_hitbox_height: float) -> void:
	var hitbox_tween: Tween = create_tween()
	if hitbox != null:
		hitbox_tween.tween_method(
			func(v: float) -> void: _set_hitbox_height(v),
			hitbox.shape.height,
			state_hitbox_height,
			height_change_duration,
		)
	else:
		hitbox_tween.tween_interval(0.1)
	hitbox_tween.finished.connect(hitbox_tween.kill)


func _set_hitbox_height(value: float) -> void:
	if hitbox.shape is CapsuleShape3D:
		hitbox.shape.height = value
	
	_update_ceiling_check()

func _update_ceiling_check() -> void:
	var height: float = hitbox.shape.height
	ceiling_check.position.y = height * 0.5
	ceiling_check.target_position = Vector3(
		0.0,
		base_hitbox_height + CEILING_CLEARANCE - height,
		0.0
	)

func tween_model_height(state_model_height: float) -> void:
	var model_tween: Tween = create_tween()
	if model != null:
		model_tween.tween_property(model, "scale:y", state_model_height, height_change_duration)
	else:
		model_tween.tween_interval(0.1)
	model_tween.finished.connect(model_tween.kill)

# =========================================================================
# Stamina
# =========================================================================

func _tick_stamina(delta: float) -> void:
	if not use_stamina:
		return
	
	if is_running or (not is_on_floor() and not is_falling):
		_drain_stamina(delta)
	else:
		_tick_stamina_cooldown(delta)
		if stamina_regen_delay_timer > 0.0:
			stamina_regen_delay_timer = max(stamina_regen_delay_timer - delta, 0.0)
		if stamina_cooldown_timer <= 0.0 and stamina_regen_delay_timer <= 0.0:
			_regen_stamina(delta)

	var should_be_visible: bool = _should_show_stamina_bar()

	if should_be_visible != _was_bar_visible:
		_was_bar_visible = should_be_visible

		if _fade_tween and _fade_tween.is_running():
			_fade_tween.kill()

		_fade_tween = create_tween()
		var target_alpha: float = 1.0 if should_be_visible else 0.0
		var target_duration: float = 0.1 if should_be_visible else 0.7
		_fade_tween.tween_property(stamina_bar, "modulate:a", target_alpha, target_duration)

	_update_can_run_and_jump()


func _drain_stamina(delta: float) -> void:
	if current_stamina <= 0.0:
		return
	current_stamina = max(current_stamina - stamina_drain_rate * delta, 0.0)
	_draining_stamina = true
	if current_stamina <= 0.0:
		_on_stamina_depleted()


func _tick_stamina_cooldown(delta: float) -> void:
	if stamina_cooldown_timer <= 0.0:
		return
	stamina_cooldown_timer = max(stamina_cooldown_timer - delta, 0.0)


func _regen_stamina(delta: float) -> bool:
	if current_stamina >= max_stamina:
		current_stamina = max_stamina
		return false
	current_stamina = min(current_stamina + stamina_regen_rate * delta, max_stamina)
	_draining_stamina = false
	return true

func _on_stamina_depleted() -> void:
	current_stamina = 0.0
	stamina_exhausted = true
	can_run = false
	can_jump = false
	stamina_cooldown_timer = stamina_cooldown
	walk_or_run = "WalkState"
	if state_machine.curr_state_name == "Run":
		state_machine.transition_to("WalkState")

func _update_can_run_and_jump() -> void:
	if stamina_cooldown_timer > 0.0:
		can_run = false
		can_jump = false
		return

	if stamina_exhausted:
		can_run = current_stamina >= max_stamina
		can_jump = current_stamina >= max_stamina
		if can_run and can_jump:
			stamina_exhausted = false
		return

	can_run = current_stamina > 0.0


func _update_flash_tween() -> void:
	var is_low_stamina: bool = current_stamina <= max_stamina * 0.3

	if is_low_stamina and _draining_stamina:
		if not _flash_tween or not _flash_tween.is_running():
			_flash_tween = create_tween().set_loops()
			_flash_tween.tween_property(stamina_bar, "tint_progress", Color(1, 0, 0, 1), 0.15)
			_flash_tween.tween_property(stamina_bar, "tint_progress", Color(1, 1, 1, 1), 0.15)
	else:
		if _flash_tween and _flash_tween.is_running():
			_flash_tween.kill()
		stamina_bar.tint_progress = Color(1, 1, 1, 1)


func _should_show_stamina_bar() -> bool:
	return (
		is_running
		or stamina_cooldown_timer > 0.0
		or (current_stamina > 0.0 and current_stamina < max_stamina)
	)

# =========================================================================
# Interaction
# =========================================================================

func _find_interact_target_from_ray() -> Node:
	_show_recticle_ui()
	if not interact_check.is_colliding():
		return null
	var collider := interact_check.get_collider() as Node
	return _find_interact_handler(collider)

func _find_interact_handler(start: Node) -> Node:
	var node := start
	while node:
		if node.has_method("interact") and _can_interact(node):
			_show_interact_ui()
			return node
		node = node.get_parent()
	return null

func _can_interact(node: Node) -> bool:
	if node.has_method("can_interact"):
		return node.can_interact(self)
	return true

func _try_interact() -> void:
	if focused_target == null:
		return
	if Input.is_action_just_pressed(interact_action):
		_currently_interacting = true
		focused_target.interact(self)

func _show_recticle_ui() -> void:
	dot_normal.show()
	dot_interact.hide()
	interact_helper_ui.hide()

func _show_interact_ui() -> void:
	dot_normal.hide()
	dot_interact.show()
	interact_helper_ui.show()

# =========================================================================
# Input map helpers
# =========================================================================

func _build_default_keybinding() -> void:
	# Built at runtime so that export variable overrides are already applied.
	default_input_actions = {
		move_forward_action: [Key.KEY_W, Key.KEY_UP] as Array[Key],
		move_backward_action: [Key.KEY_S, Key.KEY_DOWN] as Array[Key],
		move_left_action: [Key.KEY_A, Key.KEY_LEFT] as Array[Key],
		move_right_action: [Key.KEY_D, Key.KEY_RIGHT] as Array[Key],
		run_action: [Key.KEY_SHIFT] as Array[Key],
		crouch_action: [Key.KEY_C] as Array[Key],
		jump_action: [Key.KEY_SPACE] as Array[Key],
		interact_action: [Key.KEY_E] as Array[Key],
	}


func _input_actions_check() -> void:
	## Verifies that every action name is registered in the InputMap.
	## Missing actions are added at runtime with default keybindings and a warning.
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

# =========================================================================
# Utility
# =========================================================================

func show_cursor() -> void:
	cam_holder.mouse_free = true

func hide_cursor() -> void:
	cam_holder.mouse_free = false

func enter_ui_mode() -> void:
	show_cursor()
	lock_movement()

func exit_ui_mode() -> void:
	hide_cursor()
	unlock_movement()

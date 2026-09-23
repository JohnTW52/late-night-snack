extends State

class_name RunState

var state_name : String = "Run"

var play_char : CharacterBody3D

func enter(play_char_ref : CharacterBody3D) -> void:
	play_char = play_char_ref
	if !play_char.can_run:
		play_char.state_machine.transition_to("WalkState")
		return
	$run.finished.connect(_on_run_finished)
	$run.pitch_scale = 1.5
	$run.play()
	verifications()
	
func _on_run_finished() -> void:
	$run.play()
	
func verifications() -> void:
	play_char.move_speed = play_char.run_speed
	play_char.move_accel = play_char.run_accel
	play_char.move_deccel = play_char.run_deccel
	
	if play_char.floor_snap_length != 1.0: play_char.floor_snap_length = 1.0
	#if play_char.jump_cooldown > 0.0: play_char.jump_cooldown = -1.0
	if play_char.nb_jumps_in_air_allowed < play_char.nb_jumps_in_air_allowed_ref: play_char.nb_jumps_in_air_allowed = play_char.nb_jumps_in_air_allowed_ref
	if play_char.coyote_jump_cooldown < play_char.coyote_jump_cooldown_ref: play_char.coyote_jump_cooldown = play_char.coyote_jump_cooldown_ref
	
	play_char.tween_hitbox_height(play_char.base_hitbox_height)
	play_char.tween_model_height(play_char.base_model_height)
	
func physics_update(delta : float) -> void:	
	applies(delta)
	
	play_char.gravity_apply(delta)
	
	input_management()
	
	move(delta)
	
func applies(delta : float) -> void:
	if play_char.hit_ground_cooldown > 0.0: play_char.hit_ground_cooldown -= delta
		
	if !play_char.is_on_floor():
		if play_char.velocity.y < 0.0:
			$run.stop()
			transitioned.emit(self, "InairState")
			
	if play_char.is_on_floor():
		if play_char.can_jump and play_char.auto_bunny_hop and play_char.hit_ground_cooldown > 0.0 and play_char.input_direction != Vector2.ZERO and play_char.jump_cooldown <= 0.0:
			$run.stop()
			transitioned.emit(self, "JumpState")
		if play_char.can_jump and play_char.jump_buff_on and play_char.jump_cooldown <= 0.0:
			play_char.buffered_jump = true
			play_char.jump_buff_on = false
			$run.stop()
			transitioned.emit(self, "JumpState")
	
func input_management() -> void:
	if play_char.can_jump and Input.is_action_just_pressed(play_char.jump_action):
		if play_char.jump_cooldown <= 0.0:
			$run.stop()
			transitioned.emit(self, "JumpState")
		
	if Input.is_action_just_pressed(play_char.crouch_action) and play_char.can_crouch:
		$run.stop()
		transitioned.emit(self, "CrouchState")
		
	if play_char.continuous_run:
		#has to press run button once to run
		if Input.is_action_just_pressed(play_char.run_action):
			$run.stop()
			play_char.walk_or_run = "WalkState"
			transitioned.emit(self, "WalkState")
	else:
		#has to continuously press run button to run
		if !Input.is_action_pressed(play_char.run_action):
			$run.stop()
			play_char.walk_or_run = "WalkState"
			transitioned.emit(self, "WalkState")
			
func move(delta : float) -> void:
	play_char.input_direction = Input.get_vector(play_char.move_left_action, play_char.move_right_action, play_char.move_forward_action, play_char.move_backward_action)
	play_char.move_direction = (play_char.cam_holder.global_basis * Vector3(play_char.input_direction.x, 0.0, play_char.input_direction.y)).normalized()
	
	play_char.desired_move_speed = clamp(play_char.desired_move_speed, 0.0, play_char.max_desired_move_speed)
	
	if play_char.move_direction and play_char.is_on_floor() and play_char.can_run:
		play_char.velocity.x = lerp(play_char.velocity.x, play_char.move_direction.x * play_char.move_speed, play_char.move_accel * delta)
		play_char.velocity.z = lerp(play_char.velocity.z, play_char.move_direction.z * play_char.move_speed, play_char.move_accel * delta)
		
		if play_char.hit_ground_cooldown <= 0: play_char.desired_move_speed = play_char.velocity.length()
	elif play_char.move_direction and play_char.is_on_floor():
		$run.stop()
		transitioned.emit(self, "WalkState")
	else:
		$run.stop()
		transitioned.emit(self, "IdleState")

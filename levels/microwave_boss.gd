extends Microwave

@export var knockback_force := 10.0
@export var speed := 2.5

var dead: bool
var current_player: PlayerCharacter

var _gun_timer := 5.0
var _firing_timer := 2.0

@onready var target_player: PlayerCharacter 
@onready var collision := $StaticBody3D/CollisionShape3D
@onready var health := $MarginContainer2/HealthBar
@onready var death_audio := $DeathSound
@onready var hurt_audio1 := $Hurt1
@onready var hurt_audio2 := $Hurt2
@onready var spawn_audio := $Spawn
@onready var gun_audio := $Gun
@onready var laugh_audio := $EvilLaugh
@onready var muzzle_flash: Array[OmniLight3D] = [
	$MuzzleFlash,
	$MuzzleFlash2,
	$MuzzleFlash3
]

func _ready() -> void:
	target_player = owner.get_node("PlayerCharacter").get_node("PlayerCharacter")
	
	health.value = 100.0
	
	if GameManager.just_changed_level:
		show_success_screen()
	if get_tree() != null and get_tree().current_scene.name == "SecretLevel":
		timer = 30;
		GameManager.level_index = 3;
	else:
		timer = GameManager.get_timer_val()
	
	update_level_ui()

func _process(delta: float) -> void:
	if dead:
		_stop_firing()
		$hum.stop()
		return
		
	if global_position.x < 1:
		speed *= -1
	elif global_position.x > 340:
		speed *= -1

	if timer > 0.01:
		tick_timer(delta)
		update_timer_ui(timer)
	elif timer_done_not_already_emitted:
		_stop_firing()
		$hum.stop()
		timer_done_not_already_emitted = false
		microwave_timer_done.emit()
		if !laugh_audio.playing:
			laugh_audio.play()
	
	if not dead and timer > 0.01:
		position.x += speed * delta
	
	if _gun_timer <= 0.1 and timer > 0.01:
		_gun_timer = 0
		_tick_firing_timer(delta)
		if gun_audio.playing == false:
			gun_audio.play()
		if _firing_timer <= 0.1:
			_stop_firing()
			_set_firing_stats()
	
	_tick_gun_timer(delta)
	
func interact(player: PlayerCharacter) -> void:
	current_player = player
	
	if player.has_method("apply_knockback"):
		player.apply_knockback(global_position, knockback_force)
		health.value -= 10
		print(health.value)
		_calc_new_speed()
		if health.value <= 0:
			death_audio.play()
			dead = true
			change_level()
		else:
			var index := randi() % 20
			if index < 9:
				hurt_audio1.play()
			else:
				hurt_audio2.play()

func can_see_player() -> bool:
	if not target_player:
		return false

	var space_state = get_world_3d().direct_space_state
	var origin = global_transform.origin
	var target = target_player.global_transform.origin
	var query = PhysicsRayQueryParameters3D.create(origin, target)
	query.collision_mask = 1 | 2

	var result = space_state.intersect_ray(query)
	if result:
		if result.collider == target_player:
			return true
		else:
			return false
	
	return false

func remove_time(amt: float) -> void:
	timer -= amt

func _tick_gun_timer(delta: float) -> void:
	_gun_timer -= delta

func _tick_firing_timer(delta: float) -> void:
	_firing_timer -= delta

func _on_timer_2_timeout() -> void:
	if _gun_timer <= 0.1 and timer > 0.1:
		for flash in muzzle_flash:
			flash.visible = !flash.visible
		if can_see_player():
			remove_time(0.5)
			toggle_minus_time(0.5)

func _stop_firing() -> void:
	gun_audio.stop()
	for flash in muzzle_flash:
		flash.visible = false

func _set_firing_stats() -> void:
	if health.value > 66:
		_gun_timer = randf_range(4.0, 6.0)
		_firing_timer = randf_range(1.0, 1.5)
	elif health.value > 33:
		_gun_timer = randf_range(3.0, 5.0)
		_firing_timer = randf_range(2.0, 3.0)
	else:
		_gun_timer = randf_range(1.0, 2.5)
		_firing_timer = randf_range(2.5, 4.0)

func _calc_new_speed() -> void:
	if health.value >= 100.0:
			speed = 0.5
	elif health.value >= 90.0:
			speed = 0.5
	elif health.value >= 80.0:
			speed = 1
	elif health.value >= 70.0:
			speed = 2
	elif health.value >= 60.0:
			speed = 3
	elif health.value >= 50.0:
			speed = 3.5
	elif health.value >= 40.0:
			speed = 4
	elif health.value >= 30.0:
			speed = 6
	elif health.value >= 20.0:
			speed = 8
	elif health.value >= 10.0:
			speed = 10

func toggle_minus_time(time: float) -> void:
	minus_time_ui.visible = true
	minus_time_ui.get_node("Label").text = "- %.1f" % time
	await get_tree().create_timer(1.0).timeout
	minus_time_ui.visible = false

func toggle_add_time() -> void:
	add_time_ui.visible = true
	await get_tree().create_timer(1.0).timeout
	add_time_ui.visible = false

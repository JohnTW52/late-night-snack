class_name JumpBoost extends Node3D

@export var _boost_mult := 3.0 ## Higher number means higher jump


var _player: PlayerCharacter
var _default_fall_time: float
var _default_peak_time: float
@export var _boost_time := 10.0
var _boost_timer := 0.0
var _time := 0.0
var _amplitude := 0.005
var _frequency := 3.0
var _rotation_speed := 2.0
var _default_jump_height := 1.3
var _player_entered := false
var _used := false

func _ready() -> void:
	visible = true
	_used = false
	_player = null
	
func _process(delta: float) -> void:
	if _player and _boost_timer < 0.01:
		_set_player_default_stats()
		_stop_boost_timer()
		_player = null
	
	if _boost_timer > 0.01 and _player.jump_height == _default_jump_height:
		_set_player_boost_stats()
	
	if _player_entered:
		_tick_boost_timer(delta)
	
	_time += clamp(delta, 0, 1_000_000)
	global_position.y += clamp(sin(_time * _frequency) * _amplitude, deg_to_rad(-360), deg_to_rad(360))
	
	var speed = clamp(_rotation_speed * delta, -1000.0, 1000.0)
	global_rotate(Vector3.UP, speed)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name != "PlayerCharacter":
		return
	if not _used:
		if body is PlayerCharacter:
			_player = body
		
		if _player:
			_player_entered = true
			_boost_timer += _boost_time
			if _player.jump_height == _default_jump_height:
				_set_player_boost_stats()
			$bling.play()
		else:
			print("could not find player")
		
		visible = false
		_used = true

func _tick_boost_timer(delta: float) -> void:
	_boost_timer -= delta

func _stop_boost_timer() -> void: 
	_boost_timer = 0.0
	_player_entered = false

func _set_player_boost_stats() -> void:
	_default_jump_height = _player.jump_height
	_default_fall_time = _player.jump_time_to_fall
	_default_peak_time = _player.jump_time_to_peak
	_player.jump_height *= _boost_mult
	_player.jump_time_to_fall *= _boost_mult
	_player.jump_time_to_peak *= _boost_mult

func _set_player_default_stats() -> void:
	_player.jump_height = _default_jump_height
	_player.jump_time_to_fall = _default_fall_time
	_player.jump_time_to_peak = _default_peak_time

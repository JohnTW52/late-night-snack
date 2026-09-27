extends Node3D

@export var _boost_time := 5.0
var _player: PlayerCharacter
var _player_entered := false
var _used := false
var _amplitude := 0.005
var _frequency := 3.0
var _rotation_speed := 2.0
var _time := 0.0
var _boost_timer: float
var _default_run_speed: float

func _ready() -> void:
	_boost_timer = _boost_time
	visible = true
	_player = null
	_player_entered = false
	_used = false

func _process(delta: float) -> void:
	if _player_entered:
		_tick_boost_timer(delta)
	
	if _player and _boost_timer < 0.01:
		_reset_boost() 
	
	_time += clamp(delta, 0, 1_000)
	global_position.y += clamp(sin(_time * _frequency) * _amplitude, deg_to_rad(-360), deg_to_rad(360))
	var speed = clamp(_rotation_speed * delta, -1000.0, 1000.0)
	global_rotate(Vector3.UP, speed)

func _tick_boost_timer(delta: float) -> void:
	_boost_timer -= delta

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name != "PlayerCharacter":
		return
	if not _used:
		if body.name == "PlayerCharacter":
			_player = body
		
		if _player:
			_player_entered = true
			$AudioStreamPlayer3D.play()
			_default_run_speed = _player.run_speed
			_player.run_speed *= 1.5
		else:
			print("could not find player")
		
		visible = false
		_used = true

func _reset_boost() -> void:
	_player.run_speed = _default_run_speed
	_player.end_speed_boost()
	_player = null

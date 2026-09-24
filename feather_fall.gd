extends Node3D

var _player: PlayerCharacter
var _player_entered := false
var _used := false
var _amplitude := 0.005
var _frequency := 3.0
var _rotation_speed := 2.0
var _time := 0.0
var _fall_timer: float
var _fall_time := 10.0
var _fall_mult := 2.0 ## Higher number means slower fall
var _default_fall_time: float

func _ready() -> void:
	visible = true
	_fall_timer = _fall_time
	_player = null

func _process(delta: float) -> void:
	if _player and _fall_timer < 0.01:
		_stop_fall_timer()
	
	if _player_entered:
		_tick_fall_timer(delta)
	
	_time += delta
	position.y += sin(_time * _frequency) * _amplitude
	rotate(Vector3.UP, _rotation_speed * delta)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if not _used:
		if body.name == "PlayerCharacter":
			_player = body
		
		if _player:
			_player_entered = true
			_default_fall_time = _player.jump_time_to_fall
			_player.jump_time_to_fall *= _fall_mult
			$bling.play()
		else:
			print("could not find player")
		
		visible = false
		_used = true

func _tick_fall_timer(delta: float) -> void:
	_fall_timer -= delta

func _stop_fall_timer() -> void:
	_fall_timer = _fall_time
	_player_entered = false

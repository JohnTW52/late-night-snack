class_name JumpBoost extends Node3D

var _player: PlayerCharacter
var _boost_time := 10.0
var _boost_timer: float
var _boost_mult := 3.0 ## Higher number means higher jump
var _time := 0.0
var _amplitude := 0.005
var _frequency := 3.0
var _rotation_speed := 2.0
var _default_jump_height: float
var _player_entered := false
var _used := false

func _ready() -> void:
	visible = true
	_used = false
	_player = null
	_boost_timer = _boost_time
	
func _process(delta: float) -> void:
	if _player and _boost_timer < 0.01:
		_player.jump_height = _default_jump_height
		_stop_boost_timer()
	
	if _player_entered:
		_tick_boost_timer(delta)
	
	_time += delta
	position.y += sin(_time * _frequency) * _amplitude
	rotate(Vector3.UP, _rotation_speed * delta)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not _used:
		if body.name == "PlayerCharacter":
			_player = body
		
		if _player:
			_player_entered = true
			_default_jump_height = _player.jump_height
			_player.jump_height *= _boost_mult
			$bling.play()
		else:
			print("could not find player")
		
		visible = false
		_used = true

func _tick_boost_timer(delta: float) -> void:
	_boost_timer -= delta

func _stop_boost_timer() -> void: 
	_boost_timer = _boost_time
	_player_entered = false

class_name AddTime extends Node3D

@export var _time_to_add := 10.0

var _player: PlayerCharacter
var _player_entered := false
var _used := false
var _amplitude := 0.005
var _frequency := 3.0
var _rotation_speed := 2.0
var _time := 0.0
var _microwave: Node3D

func _ready() -> void:
	visible = true
	_player = null
	_player_entered = false
	_used = false
	
	_microwave = owner.get_node("Microwave")

func _process(delta: float) -> void:
	_time += delta
	position.y += sin(_time * _frequency) * _amplitude
	rotate(Vector3.UP, _rotation_speed * delta)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not _used:
		print("entered")
		
		if body.name == "PlayerCharacter":
			_player = body
		
		if _player:
			_player_entered = true
			_microwave.add_time(_time_to_add)
		else:
			print("could not find player")
		
		visible = false
		_used = true

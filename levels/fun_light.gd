extends AreaLight3D

var tween: Tween

func _ready() -> void:
	#toggle_light_loop()
	pass

func toggle_light_loop() -> void:
	if tween and tween.is_valid():
		tween.kill()
	
	tween = create_tween().set_loops()
	
	tween.tween_property(self, "light_energy", 0.0, 1.0)
	tween.tween_interval(0.1)
	tween.tween_property(self, "light_energy", 3.0, 1.0)
	tween.tween_interval(0.1)

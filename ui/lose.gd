extends CanvasLayer

@onready var microwave: Microwave

func _ready() -> void:
	hide()
	self.add_to_group("pause me")
	microwave = get_parent().get_node("Microwave")
	microwave.after_last_chance.connect(_after_last_chance)

func _after_last_chance() -> void:
	show()
	GameManager.game_over = true
	$gun.play()
	
	var t = Timer.new()
	t.add_to_group("pause me")
	t.wait_time = 2.0
	t.one_shot = true
	add_child(t)
	t.timeout.connect(func():
		GameManager.on_game_over()
		t.queue_free()
	)
	t.start()
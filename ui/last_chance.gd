extends CanvasLayer

@onready var microwave: Microwave

func _ready() -> void:
	hide()
	self.add_to_group("pause me")
	microwave = get_parent().get_node("Microwave")
	microwave.microwave_timer_done.connect(_on_microwave_timer_done)

func _on_microwave_timer_done() -> void:
	$finished.play()
	var t = Timer.new()
	t.add_to_group("pause me")
	t.wait_time = 5.0
	t.one_shot = true
	add_child(t)
	t.timeout.connect(func():
		hide()
		microwave.after_last_chance.emit()
		t.queue_free()
	)
	t.start()
	show()

extends CanvasLayer

@onready var microwave: Microwave

func _ready() -> void:
	hide()
	microwave = get_parent().get_node("Microwave")
	microwave.microwave_timer_done.connect(_on_microwave_timer_done)

func _on_microwave_timer_done() -> void:
	show()
	await get_tree().create_timer(5.0).timeout
	hide()

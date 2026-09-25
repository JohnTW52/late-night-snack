extends CharacterBody2D

@onready var sprite_2d = $Image

func _ready():
	position = get_window().size
	print(position)
	velocity = Vector2(200, 150)

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var normal = collision.get_normal()
		velocity = velocity.bounce(normal)

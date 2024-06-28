extends CharacterBody2D

class_name Bullet

@export var speed: float = 200

## The direction the bullet should travel (assumed to be a normalized vec).
var target_direction: Vector2

func _physics_process(_delta):
	velocity = target_direction * speed
	move_and_slide()
	# TODO: break bullet if it hits a wall

func _on_health_engine_is_dead():
	queue_free()

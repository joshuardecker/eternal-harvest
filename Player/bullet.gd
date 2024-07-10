extends CharacterBody2D

class_name Bullet

@export var speed: float = 200

# Some node in the 2d space the bullet can remember.
var target: Node2D

# The direction the bullet should travel, in a normalized vec.
var target_direction: Vector2

# LINEAR: the bullet moves straight at the target.
# CIRCULAR: The bullet orbits around the target.
enum movement_states {LINEAR, CIRCULAR}

# The current movement state of the bullet.
# Linear by default.
var movement_state: movement_states = movement_states.LINEAR

func _physics_process(_delta):
	match movement_state:
		movement_states.LINEAR:
			move_linearly()
		movement_states.CIRCULAR:
			move_circularly()
	
	# TODO: break bullet if it hits a wall

# Does not set the local target variable because the bullet does not
# need to track the target. The bullet only needs to know the initial
# direction of travel, and will never change after that.
func set_linear_target(pos: Vector2):
	target_direction = global_position.direction_to(pos).normalized()

func set_circular_target(new_target: Node2D):
	target = new_target

func move_linearly():
	# Move in a constant direction at a constant speed.
	velocity = target_direction * speed
	move_and_slide()

# Moves the bullet perpendicular to the target.
# Since this is called every frame,
# the bullet orbits around the target.
func move_circularly():
	# Target direction needs to be calculated every time this is called
	# because the circular orbit needs to adapt as the target moves.
	target_direction = global_position.direction_to(target.global_position).normalized()
	
	# Move perpendicular to the target at a constant speed.
	velocity = target_direction.rotated(PI / 2) * speed
	move_and_slide()

func _on_health_engine_is_dead():
	queue_free()

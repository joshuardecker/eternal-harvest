extends Node2D

## A generic class that handles the movement of bullets, projectiles,
## etc. Used for both the player and the enemies, because hiboxes
## are not included.
class_name Missile

# The parabolic projectile will move parablically (shocking) until it is
# within this many pixels of the target, then it will move straight.
const PARABOLIC_ACCURACY_RANGE: float = 100

# When within this range, the projectile will become more and more direct
# towards the target, until it hits PARABOLIC_ACCURACY_RANGE.
const PARABLIC_SEMIACCURATE_RANGE: float = PARABOLIC_ACCURACY_RANGE * 2

# Some position in the world.
# This needs to be updated every frame if you want to track
# a moving target.
var target: Vector2

enum movement_types {
	DIRECT, # Straight
	PARABOLIC # Curved
}

# How the missile currently moves.
# Straight by default.
var current_movement_type: movement_types = movement_types.DIRECT

# Returns the movement vector the missile should follow to go towards
# the target with the set movement type.
# Not responsible for movement speed, this only handles direction.
func get_movement_vec() -> Vector2:
	match current_movement_type:
		movement_types.DIRECT:
			return move_direct()
		movement_types.PARABOLIC:
			return move_parabolic()
		_:
			# Shouldnt ever reach here.
			return Vector2.ZERO

func move_direct() -> Vector2:
	return global_position.direction_to(target)

func move_parabolic() -> Vector2:
	var distance: float = (target - global_position).length()
	
	if distance < PARABOLIC_ACCURACY_RANGE:
		return move_direct()
	elif (distance > PARABOLIC_ACCURACY_RANGE) && (distance < PARABLIC_SEMIACCURATE_RANGE):
		# TODO: write this
		pass
	else:
		# TODO: write this
		pass
	
	return Vector2.ZERO

func custom_linear(num: float) -> float:
	# TODO: figure this formula out
	return num

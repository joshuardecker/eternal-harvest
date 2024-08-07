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
const PARABLIC_SEMIACCURATE_RANGE: float = PARABOLIC_ACCURACY_RANGE * 3

# Some position in the world.
# This needs to be updated every frame if you want to track
# a moving target.
var target: Vector2

# Should the projectile move parabolically clockwise or counter clockwise
# around the target.
# Generated randomly for each projectile.
var clockwise: bool

enum movement_types {
	DIRECT, # Straight
	PARABOLIC # Curved
}

# How the missile currently moves.
# Straight by default.
var current_movement_type: movement_types = movement_types.DIRECT

func _ready():
	# Randomly generate 0 or 1.
	var random: int = randi() % 2
	
	# Half the time this will make clockwise true,
	# otherwise this missile will not move clockwise.
	if random == 0:
		clockwise = true
	else:
		clockwise = false

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

# Returns the vec to move straight at the target.
func move_direct() -> Vector2:
	return global_position.direction_to(target)

# A master function that returns how the missile should move for
# parabolic motion. Moves more parabolically until the missile gets
# close to the target. Then it moves more and more directly towards
# the target.
func move_parabolic() -> Vector2:
	var distance: float = (target - global_position).length()
	
	# If the missile is very close.
	if distance < PARABOLIC_ACCURACY_RANGE:
		return move_direct()
	# If the missile is close but not very close.
	elif (distance > PARABOLIC_ACCURACY_RANGE) && (distance < PARABLIC_SEMIACCURATE_RANGE):
		return semi_parabolic(distance)
	# If the missile is far.
	else:
		return actual_parabolic()

# Returns how the missile should move when the missile is close but
# not very close to the target.
func semi_parabolic(distance: float) -> Vector2:
	# Gives a value between 0 and 1.
	# Gives 1 if the missile is PARABLIC_SEMIACCURATE_RANGE from the target.
	# Gives 0 if the missile is PARABOLIC_ACCURACY_RANGE from the target.
	# Does not matter what the constants are, this will give a value from 0 to 1.
	# This variance will be a multiplier of rotation,
	# aka the closer the missile gets, the less it will be rotated.
	var variance: float = distance - PARABOLIC_ACCURACY_RANGE
	variance /= (PARABLIC_SEMIACCURATE_RANGE - PARABOLIC_ACCURACY_RANGE)
	
	var direct_target: Vector2 = move_direct()
	
	# Rotate the target either clockwise or counter clockwise by 
	# a variant of this constant.
	var rot: float = (PI / 3) * variance
	if clockwise:
		return direct_target.rotated(-rot)
	else:
		return direct_target.rotated(rot)

# Returns how the missile should move when the target is far away.
func actual_parabolic() -> Vector2:
	var direct_target: Vector2 = move_direct()
	
	# Rotate the target either clockwise or counter clockwise by 
	# this constant.
	# This gives the projectile parabolic looking motion.
	const ROTATION: float = PI / 3
	if clockwise:
		return direct_target.rotated(-ROTATION)
	else:
		return direct_target.rotated(ROTATION)

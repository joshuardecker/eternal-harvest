extends Node2D

# Since the AI is handled here, these signals are not for movement,
# yet known here, so lets pass this information on for the parent to 
# deal with.
signal attacking_player
signal raising_allie

const SPEED: float = 60
const CHARGE_SPEED: float = SPEED * 5
const ORBIT_SPEED: float = SPEED * 8

const CHARGE_DURATION: float = 1

@onready var animation_tree: AnimationTree = $"../AnimationTree"

# The ai used to determine what type of movement to make.
var ai: GhostAI

# This needs to know where the player is to move towards them.
var player: Player

# When the ghost charges, it will not charge directly at the player.
# Instead it will have a random rotational offset. 
# Thats this number.
var charge_rotation: float

# Should the ghost orbit clockwise or counter around the player?
var orbit_clockwise: bool

# The speed of the charge attack changes over the time of its charge.
# This number counts how long the charge has been going for,
# that way a speed can be calculated.
var internal_clock: float = 0

func get_movement_vec(delta: float) -> Vector2:
	# Match what the ai says the ghost should do.
	match ai.get_decision():
		GhostAI.decision.CHASE_PLAYER:
			return direct_movement()
		GhostAI.decision.ORBIT_PLAYER:
			return oribtal_movement()
		GhostAI.decision.CHARGE_PLAYER:
			return charge_movement(delta)
		GhostAI.decision.ATTACK_PLAYER:
			attacking_player.emit()
			return Vector2.ZERO
		GhostAI.decision.SUMMON_ALLIE:
			raising_allie.emit()
			return Vector2.ZERO
		_:
			# Shouldnt ever reach this point.
			return Vector2.ZERO

func _ready():
	# Load the ai.
	ai = GhostAI.new()
	add_child(ai)
	
	player = get_tree().get_first_node_in_group("Player")
	
	# If the player does not exist.
	if not player:
		push_error("This ghost could not load a player!")
	
	# Either 0 or 1.
	var rand = randi() % 2
	
	# When the ghost is spawned, each one will randomly choose whether
	# they will later rotate clockwise or counter clockwise.
	if rand == 0:
		orbit_clockwise = true
	else:
		orbit_clockwise = false
		
	# Generate a random offset the ghost will charge at the player with.
	charge_rotation = randf_range(-PI / 4, PI / 4)

# Returns a movement vector for the ghost to move directly towards the player.
func direct_movement() -> Vector2:
	var target_position: Vector2 = global_position.direction_to(player.global_position)
	
	return target_position * SPEED

# Returns a movement vector to orbit around the player.
func oribtal_movement() -> Vector2:
	# The target directly towards the player.
	var target_to_player: Vector2 = global_position.direction_to(player.global_position)
	# The target the ghost should move towards to orbit the player.
	var target: Vector2
	
	if orbit_clockwise:
		target = target_to_player.rotated(PI / 2)
	else:
		target = target_to_player.rotated(-PI / 2)
	
	return target * ORBIT_SPEED

# Returns a movement vector to charge near the player.
func charge_movement(delta: float) -> Vector2:
	# The internal 
	if internal_clock > CHARGE_DURATION:
		# Reset the internal clock.
		internal_clock = 0
	
	internal_clock += delta
	
	# Makes the movement speed non constant, and chage over the time
	# of the charge.
	var speed_modifier: float = charge_speed_curve(internal_clock)
	
	# Dont charge directly at the player, only near.
	return rotated_movement(CHARGE_SPEED * speed_modifier)

# Returns a movement vector that goes towards, but not exactly towards
# the player. That way when the ghost charges, it wont always hit the 
# player directly, just get the ghost closer to the player.
func rotated_movement(speed: float) -> Vector2:
	var target_pos: Vector2 = global_position.direction_to(player.global_position)
	# Rotate the target position by the saved rotation.
	target_pos = target_pos.rotated(charge_rotation)
	
	return target_pos * speed

# I dont want charge speed to be constant, I want it to change as 
# the ghost charges. Linear is boring so I chose a quadratic curve:
# y = -(2 (x - 0.5)^2 + 1
# I like this curve because from x = 0 to 1, it starts at 0,
# peaks at y = 1 when x = 0.5, but then goes back down to y = 0
# when x = 1. This means if the charge attack is 1 second long,
# the charge gets faster and faster for the first half second
# of the charge, but then slows down for the second half,
# making the attack more interesting then a constant charge speed.
func charge_speed_curve(x: float) -> float:
	return -1 * (2 * (x - 0.5)) * (2 * (x - 0.5)) + 1

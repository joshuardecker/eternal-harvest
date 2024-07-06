extends Node2D

## A simple AI engine for the ghosts advanced movement type.
## Takes into account a few factors in order to determine what the ghost should
## do.
class_name GhostAI

# Explained what they are used for in log_curve().
const MAGIC_A: float = 200
const MAGIC_B: float = 230

# Factors considered to determine the ghosts action:
# These are to be set by other scripts.
@export var attack_range: float = 0 # TODO: give a number
var player_distance: float
var wave_num: int
var has_already_summoned: bool

# Saved so the ghost AI knows how far the player always is.
var player: Player

# These values are calculated in the calculate decision func.
# Not recommended to mess with these values.
var chase_player_weight: int = 5
var attack_player_weight: int = 1
var summon_allie_weight: int = 1

# The possible actions the ghost can take according to this engine.
enum decision {
	CHASE_PLAYER,
	ATTACK_PLAYER,
	SUMMON_ALLIE
}

# The last decision made by the calculate func.
# Defaults is to just chase the player because thats a safe bet.
var last_decision: decision = decision.CHASE_PLAYER

func _ready():
	# Get the player from the scene and handle if the player doesnt exist
	# for some reason.
	player = get_tree().get_first_node_in_group("Player")
	
	if not Player:
		push_error("Ghost AI engine could not find the player!")

# Every pixel that the ghost is from the player is 1 weight towards the 
# ghost going after the player. So if the ghost is 1 pixel away, not very likely 
# that it will try to chase the player. But if the ghost is 500 pixels away, 
# the 500 weight means it is very likely to chace the player.
func linear_curve(x: float) -> int:
	return floori(x)
	
# This curve is used to determine the weight of summoning an allie.
# Its easier to visualize, so I recommend plugging in this log into
# something like desmos. Basically, a log with these values is used
# because the chance of summoning an allie is 0 until the ghost
# is MAGIC_A pixels away from the player. Then it grows quickly and is the
# highest value curve, making this action the most likely one to occur.
# However, if the ghost is too far, the linear curve is larger, and therefore
# means the ghost will chase the player to get closer before it spawns an allie.
func log_curve(x: float) -> int:
	return floori(log(x - MAGIC_A) + MAGIC_B)

# Calculates a new decision on what the ghost should do.
func calculate_decision():
	# Gets the player distance at this very moment.
	player_distance = global_position.distance_to(player.global_position)
	
	# Details already explained above these funcs.
	chase_player_weight = linear_curve(player_distance)
	summon_allie_weight = log_curve(player_distance)
	
	# The weight of the ghost attacking the player is just the attack range in
	# pixels. So if the attack range is greater than the distance from the
	# player, aka the ghost can hit the player, this is the most likely thing
	# to occur.
	attack_player_weight = floori(attack_range)
	
	# Compare the weights, and highest one is chosen as the winner.
	if chase_player_weight >= attack_player_weight && chase_player_weight >= summon_allie_weight:
		last_decision = decision.CHASE_PLAYER
	elif attack_player_weight > chase_player_weight && attack_player_weight > summon_allie_weight:
		last_decision = decision.ATTACK_PLAYER
	else:
		last_decision = decision.SUMMON_ALLIE

# Repeats what the last decision was, no new decision.
func get_decision() -> int:
	return last_decision

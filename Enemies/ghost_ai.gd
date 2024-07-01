extends Node2D

## A simple AI engine for the ghosts advanced movement type.
## Takes into account a few factors in order to determine what the ghost should
## do.
class_name GhostAI

# Factors considered to determine the ghosts action:
# These are to be set by other scripts.
@export var attack_range: float = 0 # TODO: give a number
var player_distance: float
var wave_num: int
var has_already_summoned: bool

# These values are calculated in the calculate decision func.
# Not recommended to mess with these values.
var chase_player_weight: int
var attack_player_weight: int
var summon_allie_weight: int

# The possible actions the ghost can take according to this engine.
enum decision {
	chase_player,
	attack_player,
	summon_allie
}

# Used to calculate the weight of factors that grow linearly.
# Example, the chance of chasing the player increases linearly 
# the farther they are.
func linear_curve():
	pass
	
# Used to calculate logrithmic weights.
# Example, the chance of a ghost summoning an allie grows logrithmically 
# the farther the player is.
# If the player is pretty far, the linear curve will give a larger chance
# of the ghost going to the player. But once closer, the logrithmic curve
# will give the ghost a more likely opportunity to summon an allie than just
# chasing the player.
func log_curve():
	pass

# Assumes that the considered factors values have been set already.
func calculate_decision() -> decision:
	# TODO: write this algorithm
	return decision.chase_player

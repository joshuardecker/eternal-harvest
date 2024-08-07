extends Node2D

## A simple AI engine for the ghosts advanced movement type.
## Takes into account a few factors in order to determine what the ghost should
## do.
class_name GhostAI

# Explained what they are used for in log_curve().
const MAGIC_A: float = 200
const MAGIC_B: float = 230

# The chance that the ghost charges the player instead of just moving
# towards them.
const CHANCE_OF_CHARGING: int = 20

# The default odds of each event happening.
# The higher the default, the more likely it will occur.
const CHASE_PLAYER_WEIGHT: int = 4
const ORBIT_PLAYER_WEIGHT: int = 3
const CHARGE_PLAYER_WEIGHT: int = 3
const ATTACK_PLAYER_WEIGHT: int = 3
const SUMMON_ALLIE_WEIGHT: int = 0

# Every how many seconds should the ai make a new decision on what to do.
const DECISION_FREQ: float = 1

# Saved so the ghost AI knows how far the player always is.
var player: Player

# These values are calculated in the calculate decision func.
# Start as the defaults before they are randomly mutated.
var chase_player_weight: int = 4
var orbit_player_weight: int = 3
var charge_player_weight: int = 3
var attack_player_weight: int = 100
var summon_allie_weight: int = 0

# A new decision on what the ghost can do is calculated every DECISION_FREQ.
# This number simply stores how long its been since the last decison was made,
# so when this number is larger than the decision interval, a new one can be made.
var internal_clock: float = 0

# The possible actions the ghost can take.
enum decision {
	CHASE_PLAYER,
	CHARGE_PLAYER,
	ATTACK_PLAYER,
	SUMMON_ALLIE,
	ORBIT_PLAYER
}

# The current decision on what the ghost should do.
var current_decision: decision = decision.CHASE_PLAYER

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	
	# If the player could not be loaded.
	if not Player:
		push_error("Ghost AI could not find the player!")

func _process(delta):
	# Time has passed, so add it to the clock.
	internal_clock += delta
	
	# If its time to make a new decision on what to do.
	if internal_clock > DECISION_FREQ:
		calculate_new_decision()
		
		# Reset the internal clock.
		internal_clock = 0

# Reset all of the weights to their default values.
# Called every new decision.
func reset_weights():
	chase_player_weight = CHASE_PLAYER_WEIGHT
	orbit_player_weight = ORBIT_PLAYER_WEIGHT
	charge_player_weight = CHARGE_PLAYER_WEIGHT
	attack_player_weight = ATTACK_PLAYER_WEIGHT
	summon_allie_weight = SUMMON_ALLIE_WEIGHT

func calculate_new_decision():
	reset_weights()
	
	# Randomize the weight values.
	# The higher the default value, the more likely they
	# will be a larger number.
	chase_player_weight = random_weight(chase_player_weight)
	orbit_player_weight = random_weight(orbit_player_weight)
	charge_player_weight = random_weight(charge_player_weight)
	attack_player_weight = random_weight(attack_player_weight)
	summon_allie_weight = random_weight(summon_allie_weight)
	
	# Put all of the values into an array to be sorted.
	var weight_array: Array[int] = []
	weight_array.append(chase_player_weight)
	weight_array.append(orbit_player_weight)
	weight_array.append(charge_player_weight)
	weight_array.append(attack_player_weight)
	weight_array.append(summon_allie_weight)
	
	weight_array.sort()
	
	# Get the highest value.
	var highest_weight: int = weight_array.pop_back()
	
	# We know the largest value know, so lets quickly
	# remember which weight had that value, and then return its 
	# corresponding decision.
	match highest_weight:
		chase_player_weight:
			current_decision = decision.CHASE_PLAYER
		orbit_player_weight:
			current_decision = decision.ORBIT_PLAYER
		charge_player_weight:
			current_decision = decision.CHARGE_PLAYER
		attack_player_weight:
			current_decision = decision.ATTACK_PLAYER
		summon_allie_weight:
			current_decision = decision.SUMMON_ALLIE

# Randonly multiply the number by a int from 1 to 5.
func random_weight(weight: int) -> int:
	return weight * randi_range(1, 5)

# Repeats what the last decision was, no new decision.
func get_decision() -> int:
	return current_decision

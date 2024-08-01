extends CharacterBody2D

# TODO: update description to no longer say 'will' when actually added.
## The ghost is the basic enemy of the game. It will have a couple movement types,
## customizable health and drops, and even a boss mode.
## Only chases the player.
class_name Ghost

# Kind of redundant, but this exists so I can link this signal to the game manager
# and dont have to hook the HealthEngine to the game manager.
signal dead

@export_enum("simple_movement", "ai_movement") var movement_type: String = "simple_movement"

const SPEED: float = 60
const CHARGE_SPEED: float = SPEED * 5

# How often in seconds the AI engine should make a new decision on what to do.
const AI_DECISION_FREQ: float = 1

# How long it will take the ghost to summon an allie in seconds.
const SUMMON_TIME: float = 5

# Use the animation tree to manipulate the ghost sprite.
# This animation player should only be used to mess with the other sprites that
# dont care about the ghosts movement state.
@onready var animation_player = $AnimationPlayer
@onready var ghost_sprite = $Sprites/GhostSprite
@onready var death_sprite = $Sprites/DeathSprite
@onready var summon_sprite = $Sprites/SummonSprite
@onready var animation_tree = $AnimationTree
@onready var hitbox_shape = $Hitbox/CollisionShape

var ghost_ai: GhostAI 

var player: Player
var stats_manager: StatsManager

# How long in seconds since the AIEngine made a new decision on what to do.
var last_ai_decision_time: float
# Keeps track if this ghost has already summoned an allie.
# Ghosts can only summon one, so this is useful to make sure
# multiple arnt summoned.
var has_summoned_allie: bool = false

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	
	# If the player does not exist, just despawn.
	if not player:
		despawn()
		return
		
	stats_manager = get_tree().get_first_node_in_group("StatsManager")
	
	# If the stats manager could not be found.
	if not stats_manager:
		push_error("This ghost could not find the stats manager!")
		
	# Creates and adds the ghostai to the scene.
	# Needs to be added to the scene because the ghostai script searches
	# the scene tree for the player.
	ghost_ai = GhostAI.new()
	add_child(ghost_ai)

func _process(delta: float):
	move(delta)

# Loads ther entity manager, that way the ghost can despawn.
# Despawning any entity must go through the entity manager.
# Since this ghost is already spawned, we know the entity
# manager exists.
func load_entity_manager() -> EntityManager:
	return get_tree().get_first_node_in_group("EntityManager")

func despawn():
	var entity_manager = load_entity_manager()
	entity_manager.despawn_ghost(self)

func fancy_death():
	dead.emit()
	
	# Hide the ghost sprite so the death sprite can replace it.
	ghost_sprite.hide()
	
	# Also make sure the summoning animation isnt playing.
	# NOTE: this doesnt stop the summoning ability from continuing,
	# so it is possible for a ghost to be summoned while this ghost is in
	# the death animation.
	summon_sprite.hide()
	
	# despawn() is called when death animation finishes.
	animation_tree.get("parameters/playback").travel("death")
	death_sprite.show()
	
	# When the ghost is dead but playing the death animation, make it so it 
	# cant hurt the player.
	hitbox_shape.disabled = true
	
	drop_items()
	
	# Tell the stats manager that the player got a kill.
	stats_manager.update_player_kills()

func drop_items():
	print("I need to drop items!")

func _on_health_engine_is_dead():
	# Always use call deferred when calling a death func.
	# It guarantees it only runs once when the game engine is ready for it.
	# No errors, no nothing.
	call_deferred("fancy_death")
	
func move(delta: float):
	match movement_type:
		"simple_movement":
			simple_movement(SPEED)
		"ai_movement":
			ai_movement(delta)
		_:
			push_error("This ghost is using a movement engine that doesnt exist!")

# Moves the ghost directly toward the players current position.
func simple_movement(speed: float):
	var target_position = global_position.direction_to(player.global_position)
	velocity = target_position * speed
	move_and_slide()
	
	# Update the animation player to make the ghost face the correct direction.
	animation_tree.set("parameters/Move/blend_position", target_position)

# Takes the feedback from the GhostAI engine and performs the action.
func ai_movement(delta: float):
	# Remember a total of how long since the last ai decision was made.
	last_ai_decision_time += delta
	
	# If its been long enough, calculate a new decison on what to do.
	# This doesnt mean behavior will change since the same answer can be
	# given again by calculate_decision, but it could change.
	if last_ai_decision_time > AI_DECISION_FREQ:
		call_deferred("new_ai_decision")
		
	match ghost_ai.get_decision():
		GhostAI.decision.CHASE_PLAYER:
			# TODO: make the movement more advanced.
			simple_movement(SPEED)
		GhostAI.decision.SUMMON_ALLIE:
			# If an allie has yet to be summoned.
			if !has_summoned_allie:
				has_summoned_allie = true
				call_deferred("summon_allie")
			# An allie has already been summoned, so just keep moving.
			else:
				simple_movement(SPEED)
		GhostAI.decision.CHARGE_PLAYER:
			charge_player()
		_:
			print("I tried to ", ghost_ai.get_decision())

# Calculate a new decision and reset the timer affecting when a new decision 
# will be made.
func new_ai_decision():
	ghost_ai.calculate_decision()
	
	# Reset time since a decision was made.
	last_ai_decision_time = 0

func summon_allie():
	# Start the summon animation around the ghost.
	animation_player.play("summon")
	summon_sprite.show()
	
	# Create and initialize a timer for how long it takes a new
	# ghost to be summoned.
	var timer = Timer.new()
	timer.autostart = false
	timer.one_shot = true
	add_child(timer)
	
	timer.start(SUMMON_TIME)
	
	# Wait for the timer to finish.
	await timer.timeout
	
	# Clean up the timer since its done being used.
	remove_child(timer)
	timer.queue_free()
	
	# Hide the animation now that its done.
	summon_sprite.hide()
	animation_player.stop()
	
	# TODO: summon another ghost
	
func charge_player():
	var speed_modifier: float = charge_speed_curve(last_ai_decision_time)
	
	simple_movement(speed_modifier * CHARGE_SPEED)

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

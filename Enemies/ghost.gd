extends CharacterBody2D

# TODO: update description to no longer say 'will' when actually added.
## The ghost is the basic enemy of the game. It will have a couple movement types,
## customizable health and drops, and even a boss mode.
## Only chases the player.
class_name Ghost

# Kind of redundant, but this exists so I can link this signal to the game manager
# and dont have to hook the HealthEngine to the game manager.
signal dead

@export var speed: float = 20
@export_enum("simple_movement", "ai_movement") var movement_type: String = "simple_movement"
## How long it will take the ghost to summon an allie in seconds.
@export var summon_time: float = 5
## How often in seconds the AI engine should make a new decision on what to do.
@export var ai_decision_time_freq: float = 1

# Use the animation tree to manipulate the ghost sprite.
# This animation player should only be used to mess with the other sprites that
# dont care about the ghosts movement state.
@onready var animation_player = $AnimationPlayer
@onready var ghost_sprite = $GhostSprite
@onready var death_sprite = $DeathSprite
@onready var summon_sprite = $SummonSprite

@onready var animation_tree = $AnimationTree
@onready var hitbox_shape = $Hitbox/CollisionShape
@onready var ghost_ai: GhostAI = $GhostAI

var player: Player

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
		
	# When the player dies, despawn the ghost.
	player.connect("is_dead", despawn)
	
	# Load a local instance of the hud.
	var hud = get_tree().get_first_node_in_group("HUD")
	if not hud:
		push_error("This ghost tried to load the hud and it couldnt!")
	
	# When the ghost dies, tell the hud to add one to the kill counter.
	connect("dead", hud.update_kill_amount)

func _process(delta: float):
	move(delta)

func despawn():
	queue_free()

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
	animation_player.play("death")
	death_sprite.show()
	
	# When the ghost is dead but playing the death animation, make it so it 
	# cant hurt the player.
	hitbox_shape.disabled = true
	
	drop_items()

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
			simple_movement()
		"ai_movement":
			ai_movement(delta)
		_:
			push_error("This ghost is using a movement engine that doesnt exist!")

# Moves the ghost directly toward the players current position.
func simple_movement():
	var target_position = self.global_position.direction_to(player.global_position)
	velocity = target_position * speed
	move_and_slide()
	
	# Update the animation player to make the ghost face the correct direction.
	animation_tree.set("parameters/Move/blend_position", velocity)

# Takes the feedback from the GhostAI engine and performs the action.
func ai_movement(delta: float):
	# Remember a total of how long since the last ai decision was made.
	last_ai_decision_time += delta
	
	# If its been long enough, calculate a new decison on what to do.
	# This doesnt mean behavior will change since the same answer can be
	# given again by calculate_decision, but it could change.
	if last_ai_decision_time > ai_decision_time_freq:
		ghost_ai.calculate_decision()
		
		# Reset time since a decision was made.
		last_ai_decision_time = 0
	
	match ghost_ai.get_decision():
		GhostAI.decision.CHASE_PLAYER:
			# TODO: make the movement more advanced.
			simple_movement()
		GhostAI.decision.SUMMON_ALLIE:
			# If an allie has yet to be summoned.
			if !has_summoned_allie:
				has_summoned_allie = true
				call_deferred("summon_allie")
			# An allie has already been summoned, so just keep moving.
			else:
				simple_movement()
		_:
			print("I tried to ", ghost_ai.get_decision())

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
	
	timer.start(summon_time)
	
	# Wait for the timer to finish.
	await timer.timeout
	
	# Clean up the timer since its done being used.
	remove_child(timer)
	timer.queue_free()
	
	# Hide the animation now that its done.
	summon_sprite.hide()
	animation_player.stop()
	
	# TODO: summon another ghost

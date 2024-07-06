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

@onready var animation_tree = $AnimationTree
@onready var hitbox_shape = $Hitbox/CollisionShape
@onready var ghost_ai: GhostAI = $GhostAI

var player: Player

# How long in seconds since the AIEngine made a new decision on what to do.
var last_ai_decision_time: float
## How often in seconds the AI engine should make a new decision on what to do.
@export var ai_decision_time_freq: float = 1

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
	
	# TODO: fancy death animation.
	
	# When the ghost is dead but playing the death animation, make it so it 
	# cant hurt the player.
	hitbox_shape.disabled = true
	
	drop_items()
	
	despawn()

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
		_:
			print("I tried to ", ghost_ai.get_decision())

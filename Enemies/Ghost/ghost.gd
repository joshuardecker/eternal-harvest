extends CharacterBody2D

## The ghost is the basic enemy of the game. It has a couple movement types,
## customizable health and drops, and even a boss mode.
## Only chases the player.
class_name Ghost

const SPEED: float = 60
const CHARGE_SPEED: float = SPEED * 7
const ORBIT_SPEED: float = SPEED * 4

const CHARGE_DURATION: float = 1
const DEATH_ANIMATION_LEN: float = 0.5

@onready var ghost_sprite = $Sprites/GhostSprite
@onready var death_sprite = $Sprites/DeathSprite
@onready var animation_tree = $AnimationTree
@onready var hitbox_shape = $Hitbox/CollisionShape

var ghost_ai: GhostAI 

var player: Player
var stats_manager: StatsManager

# When the ghost charges, it will not charge directly at the player.
# Instead it will have a random rotational offset. 
# Thats this number.
var charge_rot: float

# Should the ghost orbit clockwise or counter around the player?
var orbit_clockwise: bool

# An internal clock used for the charge attack.
# The charge attack needs to know how long it has been going for,
# so this stores that value.
var internal_clock: float = 0

func _ready():
	# We will check if the player exists every frame.
	player = get_tree().get_first_node_in_group("Player")
	
	stats_manager = get_tree().get_first_node_in_group("StatsManager")
	
	# If the stats manager could not be found.
	if not stats_manager:
		push_error("This ghost could not find the stats manager!")
		
	# Creates and adds the ghostai to the scene.
	# Needs to be added to the scene because the ghostai script searches
	# the scene tree for the player.
	ghost_ai = GhostAI.new()
	add_child(ghost_ai)
	
	# Either 0 or 1.
	var rand = randi() % 2
	
	# When the ghost is spawned, each one will randomly choose whether
	# they will later rotate clockwise or counter clockwise.
	if rand == 0:
		orbit_clockwise = true
	else:
		orbit_clockwise = false

# Loads ther entity manager, that way the ghost can despawn.
# Despawning any entity must go through the entity manager.
# Since this ghost is already spawned, we know the entity
# manager exists.
func load_entity_manager() -> EntityManager:
	return get_tree().get_first_node_in_group("EntityManager")

func despawn():
	# Tell the entity manager to remove this ghost.
	var entity_manager = load_entity_manager()
	entity_manager.despawn_ghost(self)

func drop_items():
	print("I need to drop items!")

func fancy_death():
	# Hide the ghost sprite so the death sprite can replace it.
	ghost_sprite.hide()
	
	animation_tree.get("parameters/playback").travel("death")
	death_sprite.show()
	
	# When the ghost is dead but playing the death animation, make it so it 
	# cant hurt the player.
	hitbox_shape.disabled = true
	
	drop_items()
	
	# Tell the stats manager that the player got a kill.
	stats_manager.update_player_kills()
	
	# Create a timer to trigger despawning after the death animation.
	# I used to call despawn from the death animation itself, but it
	# wouldnt always call it for some reason.
	var timer = Timer.new()
	
	timer.one_shot = true
	add_child(timer)
	
	timer.start(DEATH_ANIMATION_LEN)
	
	await timer.timeout
	despawn()

func _on_health_engine_is_dead():
	# Always use call deferred when calling a death func.
	# It guarantees it only runs once when the game engine is ready for it.
	# No errors, no nothing.
	call_deferred("fancy_death")

func _process(delta: float):
	# If the player does not exist, just despawn.
	if not player:
		despawn()
		return
	
	move(delta)
	
	# If the internal clock for the charge animation has counted longer
	# than the animation itself will take, its time to reset it.
	if internal_clock > CHARGE_DURATION:
		# Reset the internal clock.
		internal_clock = 0

# Takes the feedback from the GhostAI engine and performs the action.
func move(delta: float):
	match ghost_ai.get_decision():
		GhostAI.decision.CHASE_PLAYER:
			simple_movement(SPEED)
		GhostAI.decision.ORBIT_PLAYER:
			oribtal_movement(ORBIT_SPEED)
		GhostAI.decision.CHARGE_PLAYER:
			charge_movement(CHARGE_SPEED, delta)
		GhostAI.decision.ATTACK_PLAYER:
			call_deferred("attack_player")
		GhostAI.decision.SUMMON_ALLIE:
			summon_allie()

# Moves the ghost directly toward the players current position.
func simple_movement(speed: float):
	var target_position = global_position.direction_to(player.global_position)
	velocity = target_position * speed
	move_and_slide()
	
	# Update the animation player to make the ghost face the correct direction.
	animation_tree.set("parameters/move/blend_position", target_position)

# Moves the ghost towards the player, but with a slight rotational offset,
# that way it is near but not directly to the player.
func rotated_movement(speed: float):
	# If a rotation has not yet been calculated, calculate it.
	if charge_rot == 0:
		charge_rot = randf_range(-PI / 4, PI / 4)
	
	var target_pos: Vector2 = global_position.direction_to(player.global_position)
	# Rotate the target position by the saved rotation.
	target_pos = target_pos.rotated(charge_rot)
	
	velocity = target_pos * speed
	move_and_slide()
	
	# Update the animation player to make the ghost face the correct direction.
	animation_tree.set("parameters/move/blend_position", target_pos)

# Orbit around the player.
func oribtal_movement(speed: float):
	# The target directly towards the player.
	var target_to_player: Vector2 = global_position.direction_to(player.global_position)
	# The target the ghost should move towards to orbit the player.
	var target: Vector2
	
	if orbit_clockwise:
		target = target_to_player.rotated(PI / 2)
	else:
		target = target_to_player.rotated(-PI / 2)
		
	velocity = target * speed
	move_and_slide()
	
	# Face towards the player while orbiting around.
	animation_tree.set("parameters/move/blend_position", target_to_player)

# Charge towards the player.
func charge_movement(speed: float, delta):
	internal_clock += delta
	
	# Makes the movement speed non constant, and chage over the time
	# of the charge.
	var speed_modifier: float = charge_speed_curve(internal_clock)
	
	# Dont charge directly at the player, only near.
	rotated_movement(speed * speed_modifier)

func summon_allie():
	# This is getting completely reworked,
	# for now do nothing.
	print("I summoned an allie!")

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

func attack_player():
	animation_tree.set("parameters/attack/blend_position", global_position.direction_to(player.global_position))
	animation_tree.get("parameters/playback").travel("attack")

# Called by the attack animation when its finished.
func finished_attacking():
	animation_tree.get("parameters/playback").travel("move")

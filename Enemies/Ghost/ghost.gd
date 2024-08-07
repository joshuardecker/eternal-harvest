extends CharacterBody2D

## The ghost is the basic enemy of the game. It has a couple movement types,
## customizable health and drops, and even a boss mode.
## Only chases the player.
class_name Ghost

# In seconds.
const DEATH_ANIMATION_LEN: float = 0.5

@onready var movement: Node2D = $Movement

@onready var ghost_sprite = $Sprites/GhostSprite
@onready var death_sprite = $Sprites/DeathSprite
@onready var animation_tree = $AnimationTree
@onready var hitbox_shape = $Hitbox/CollisionShape

var stats_manager: StatsManager
var entity_manager: EntityManager
var player: Player

# Turned to true when the ghost dies.
# That way the ghost cant die multiple times.
var has_died: bool = false

func _ready():
	# We will check if the player exists every frame.
	player = get_tree().get_first_node_in_group("Player")
	
	# If the player does not exist.
	if not player:
		push_error("This ghost could not load the player!")
	
	stats_manager = get_tree().get_first_node_in_group("StatsManager")
	
	# If the stats manager does not exist.
	if not stats_manager:
		push_error("This ghost could not load the stats manager!")
	
	entity_manager = get_tree().get_first_node_in_group("EntityManager")
	
	# If the entity manager does not exist.
	if not entity_manager:
		push_error("This ghost could not load the entity manager!")
	
	# The movement component passes on useful information on
	# what the ai is doing. These actions are not only movement,
	# so the parent (this node) needs to know about it to
	# call the corresponding functions.
	movement.connect("attacking_player", attack_player)
	movement.connect("raising_allie", summon_allie)

func _process(delta: float):
	# If the player does not exist, just despawn.
	if not player:
		despawn()
		return
		
	velocity = movement.get_movement_vec(delta)
	move_and_slide()

# For the ghost to have a death animation, drops items, etc
# call this function, not despawn.
func fancy_death():
	# If the ghost has already died, dont run this again.
	if has_died:
		return
	else:
		has_died = true
	
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

# Tells the entity manager to remove this ghost.
func despawn():
	entity_manager.despawn_ghost(self)

# Drop items for the player to pickup.
func drop_items():
	# TODO: drop items.
	pass

func _on_health_engine_is_dead():
	# More thread safe way of calling the death function.
	call_deferred("fancy_death")

func summon_allie():
	# TODO: add allie summoning.
	pass

func attack_player():
	# TODO: write attack component and have it attack the player.
	animation_tree.set("parameters/attack/blend_position", global_position.direction_to(player.global_position))
	animation_tree.get("parameters/playback").travel("attack")

# Called by the attack animation when its finished.
func finished_attacking():
	animation_tree.get("parameters/playback").travel("move")

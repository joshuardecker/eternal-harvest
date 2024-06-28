extends CharacterBody2D

# TODO: update description to no longer say 'will' when actually added.
## The ghost is the basic enemy of the game. It will have a couple movement types,
## customizable health and drops, and even a boss mode.
## Only chases the player.
class_name Ghost

@export var speed: float = 20
@export_enum("simple_movement", "ai_movement") var movement_type: String = "simple_movement"

@onready var animation_player = $AnimationPlayer
@onready var hitbox_shape = $Hitbox/CollisionShape

# Kind of redundant, but this exists so I can link this signal to the game manager.
signal dead

var player: Player

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	
	# If the player does not exist, just despawn.
	if not player:
		despawn()
		return
		
	# When the player dies, despawn the ghost.
	player.connect("is_dead", despawn)
	
	animation_player.play("idle")
	
	# Load a local instance of the hud.
	var hud = get_tree().get_first_node_in_group("HUD")
	if not hud:
		push_error("This ghost tried to load the hud and it couldnt!")
	
	# When the ghost dies, tell the hud to add one to the kill counter.
	connect("dead", hud.update_kill_amount)

func _physics_process(_delta):
	move()

func despawn():
	queue_free()

func fancy_death():
	dead.emit()
	
	# The death animation automatically calls despawn after its finished.
	animation_player.play("death")
	
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
	
func move():
	match movement_type:
		"simple_movement":
			move_simply()
		"ai_movement":
			pass
		_:
			push_error("This ghost is using a movement engine that doesnt exist!")

# Moves the ghost directly toward the players current position.
func move_simply():
	var target_position = self.global_position.direction_to(player.global_position)
	velocity = target_position * speed
	move_and_slide()

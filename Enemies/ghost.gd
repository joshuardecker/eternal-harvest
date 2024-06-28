extends CharacterBody2D

# TODO: update description to no longer say 'will' when actually added.
## The ghost is the basic enemy of the game. It will have a couple movement types,
## customizable health and drops, and even a boss mode.
## Only chases the player.
class_name Ghost

@export var speed: float = 20
@export_enum("simple_movement", "ai_movement") var movement_type: String = "simple_movement"

@onready var animation_player = $AnimationPlayer

var player: Player

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	
	# If the player does not exist, just despawn.
	if not player:
		despawn()
		
	# When the player dies, despawn the ghost.
	player.connect("is_dead", despawn)
	
	animation_player.play("idle")

func _physics_process(_delta):
	move()

func despawn():
	# TODO: properly handle despawning
	print("I need to despawn!")

func fancy_death():
	# The death animation automatically calls despawn after its finished.
	animation_player.play("death")
	drop_items()

func drop_items():
	# TODO: add actual drops
	print("I dropped something!")

func _on_health_engine_is_dead():
	despawn()
	
func move():
	match movement_type:
		"simple_movement":
			move_simply()
		"ai_movement":
			pass
		_:
			push_error("This ghost is using a movement engine that doesnt exist!")

func move_simply():
	var target_position = self.global_position.direction_to(player.global_position)
	
	velocity = target_position * speed
	move_and_slide()

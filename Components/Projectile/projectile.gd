extends CharacterBody2D

## A generic projectile class that both the player and enemys can use. 
## Mostly handles movement and target tracking. Each type of projectile
## needs a custom hitbox, health engine, and collision shape.
class_name Projectile

@export var speed: float = 1000

# Some node in the 2d space the bullet can remember.
var target: Node2D

# The direction the bullet should travel, in a normalized vec.
var target_direction: Vector2

# LINEAR: the bullet moves straight at the target.
# CIRCULAR: The bullet orbits around the target.
enum movement_states {LINEAR, CIRCULAR}

# The current movement state of the bullet.
# Linear by default.
var movement_state: movement_states = movement_states.LINEAR

# A local copy of the entity manager. Used to properly spawn and despawn.
var entity_manager: EntityManager

func _ready():
	# Load the entity manager.
	entity_manager = get_tree().get_first_node_in_group("EntityManager")
	
	# If the entity manager could not be loaded.
	if not entity_manager:
		push_error("This projectile could not load the entity manager!")
		
	# Right now the projectile is a child of whoever spawned it.
	# A ghost, player, etc. It needs to be part of the scene tree
	# to get the entity manager. However, the entity manager will
	# load this projectile elsewhere. So the projectile loses the 
	# current parent to get a new one.
	get_parent().remove_child(self)
		
	entity_manager.load_projectile(self)
	
	var health_engine: HealthComponent
	
	# Automatically try to load a child HealthEngine.
	for child in get_children():
		if child is HealthComponent:
			health_engine = child
			break
			
	# If a health engine was not found as a child.
	if not health_engine:
		push_error("This projectile could not load a HealthEngine!")
		
	health_engine.connect("is_dead", despawn)

func _physics_process(_delta):
	match movement_state:
		movement_states.LINEAR:
			move_linearly()
		movement_states.CIRCULAR:
			move_circularly()
	
	# TODO: break bullet if it hits a wall

# Does not set the local target variable because the bullet does not
# need to track the target. The bullet only needs to know the initial
# direction of travel, and will never change after that.
func set_linear_target(pos: Vector2):
	target_direction = global_position.direction_to(pos).normalized()

func set_circular_target(new_target: Node2D):
	target = new_target

func move_linearly():
	# Move in a constant direction at a constant speed.
	velocity = target_direction * speed
	move_and_slide()

# Moves the bullet perpendicular to the target.
# Since this is called every frame,
# the bullet orbits around the target.
func move_circularly():
	# Target direction needs to be calculated every time this is called
	# because the circular orbit needs to adapt as the target moves.
	target_direction = global_position.direction_to(target.global_position).normalized()
	
	# Move perpendicular to the target at a constant speed.
	velocity = target_direction.rotated(PI / 2) * speed
	move_and_slide()

func despawn():
	entity_manager.call_deferred("despawn_projectile", self)

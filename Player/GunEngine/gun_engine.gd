extends Node2D

## The gun used by the player. Not intended for anyone else. Can shoot, and 
## thats pretty much it. How it shoots is customizable.
class_name GunEngine

## Pixels per second the bullet moves.
@export var speed: float = 200
@export var damage: float = 40

@onready var animation_tree = $"../AnimationTree"

# Normally the bullet will spawn at the base of the player.
# This is not where the gun is, so lets move the bullet up by an arbitrary
# magic value.
const MAGIC_VALUE = Vector2(0, -8)

var bullet_scene: PackedScene = load("res://Player/Projectile/player_projectile.tscn")

# The direction the bullet will travel. 
# Note: this should be normalized (length of 1).
var direction_vec: Vector2

var player: Player

func _ready():
	# I get the player this way because it will work globally, no matter where
	# GunEngine is. Error proofing for the future.
	player = get_tree().get_first_node_in_group("Player")
	
	if not player:
		push_error("GunEngine has tried to get the player, but it doesnt exist!")
		return
		
	player.connect("shoot", shoot_single_bullet)
	
func shoot_single_bullet():
	# Makes the bullet travel towards the mouse (at the time of clicking).
	var target = player.global_position.direction_to(get_global_mouse_position())
	
	# Spawn the bullet and add it to the scene.
	var new_bullet: Projectile = bullet_scene.instantiate()
	
	add_child(new_bullet)
	
	new_bullet.global_position = player.global_position
	new_bullet.global_position += MAGIC_VALUE
	
	# Finally set the calculated target to the bullet.
	# Not all on one line to make easier to read.
	new_bullet.target_direction = target
	
	# Make the player have a shoot animation (in the correct direction).
	animation_tree.set("parameters/Shoot/blend_position", target)
	animation_tree.set("parameters/conditions/is_shooting", true)
	
	# Manually tell the animation tree to play the shoot animation.
	# If you try to automatically, it throws errors because recursion is 
	# a possibility according to the compiler.
	# Still have an is_shooting parameter because its useful information
	# for the player to have access to.
	animation_tree.get("parameters/playback").travel("Shoot")

# Called automatically at the end of the shooting animations.
func can_shoot_again():
	# No longer say the player is shooting.
	animation_tree.set("parameters/conditions/is_shooting", false)

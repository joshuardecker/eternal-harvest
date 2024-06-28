extends Node2D

## The gun used by the player. Not intended for anyone else. Can shoot, and 
## thats pretty much it. How it shoots is customizable.
class_name GunEngine

## Pixels per second the bullet moves.
@export var speed: float = 200
@export var damage: float = 40

@onready var bullet: PackedScene = load("res://Player/bullet.tscn")

# Normally the bullet will spawn at the base of the player.
# This is not where the gun is, so lets move the bullet up by an arbitrary
# magic value.
const MAGIC_VALUE = Vector2(0, -8)

## The direction the bullet will travel. 
## Note: this should be normalized (length of 1).
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
	var target = player.global_position.direction_to(get_global_mouse_position())
	
	var new_bullet: Bullet = bullet.instantiate()
	
	new_bullet.global_position = player.global_position
	
	new_bullet.global_position += MAGIC_VALUE
	
	get_tree().root.add_child(new_bullet)
	
	new_bullet.target_direction = target

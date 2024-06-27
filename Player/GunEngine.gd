extends Node2D

## The gun used by the player. Not intended for anyone else. Can shoot, and 
## thats pretty much it. How it shoots is customizable.
class_name GunEngine

## Pixels per second the bullet moves.
@export var speed: float = 200
@export var damage: float = 40

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
	# TODO: spawn the bullet and shoot
	print("Pretend the player is shooting!")

extends CharacterBody2D

## An instance of the main player controlled directly by the user of the game.
## Only intended for one of these to exist at a time.
## Can be created and deleted at will assuming what the user is looking
## at is handled.
class_name Player

## Pixels per second the player moves.
@export var speed: float = 100

@onready var animation_tree = $AnimationTree

# The last direction the player moved, that way the correct idle direction can be displayed.
var last_moving_velocity: Vector2

func _ready():
	pass

func _physics_process(_delta: float):
	move()

func move():
	velocity = Vector2.ZERO
	
	# A bunch of if statements because I want all of these actions to be checked every frame
	# not just break when one of them is chosen. 
	if Input.is_action_pressed("up"):
		velocity.y -= 1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	if Input.is_action_pressed("left"):
		velocity.x -= 1
	if Input.is_action_pressed("right"):
		velocity.x += 1
	
	# A Vector of (1,1) (right,down) has a longer length than (1,0)
	# just going right, so the player would move faster.
	# .normalized() makes the length always 1.
	velocity = velocity.normalized() * speed
	
	if velocity != Vector2.ZERO:
		animation_tree.set("parameters/Walk/blend_position", velocity)
		animation_tree.set("parameters/conditions/is_moving", true)
		animation_tree.set("parameters/conditions/is_idling", false)
		
		# Shouldnt be zero since its last direction the player moved.
		# Zero is not a direction to move to.
		last_moving_velocity = velocity
	else:
		animation_tree.set("parameters/Idle/blend_position", last_moving_velocity)
		animation_tree.set("parameters/conditions/is_moving", false)
		animation_tree.set("parameters/conditions/is_idling", true)
	
	move_and_slide()

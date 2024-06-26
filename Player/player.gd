extends CharacterBody2D

## An instance of the main player controlled directly by the user of the game.
## Only intended for one of these to exist at a time.
## Can be created and deleted at will assuming what the user is looking
## at is handled.
class_name Player

## Pixels per second the player moves.
@export var speed: float = 100

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
		
	move_and_slide()

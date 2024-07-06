extends CharacterBody2D

## An instance of the main player controlled directly by the user of the game.
## Only intended for one of these to exist at a time.
## Can be created and deleted at will assuming what the user is looking
## at is handled.
class_name Player

## Pixels per second the player moves.
@export var speed: float = 100

@onready var animation_tree = $AnimationTree

# Engines:
@onready var health_engine = $HealthEngine

# The last direction the player moved, that way the correct idle direction can be displayed.
var last_moving_velocity: Vector2

## When the player shoots.
signal shoot
signal took_damage(health_now: float)
## When the player dies.
signal is_dead

func _ready():
	pass

func _process(_delta):
	check_if_shoot()
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
	
	# If the player is shooting, dont let the player move.
	if animation_tree.get("parameters/conditions/is_shooting"):
		return
	
	if velocity != Vector2.ZERO:
		animation_tree.set("parameters/Walk/blend_position", velocity)
		animation_tree.set("parameters/conditions/is_walking", true)
		animation_tree.set("parameters/conditions/is_idling", false)
		
		# Shouldnt be zero since its last direction the player moved.
		# Zero is not a direction to move to.
		last_moving_velocity = velocity
	else:
		animation_tree.set("parameters/Idle/blend_position", last_moving_velocity)
		animation_tree.set("parameters/conditions/is_walking", false)
		animation_tree.set("parameters/conditions/is_idling", true)
	
	move_and_slide()

func check_if_shoot():
	if Input.is_action_just_pressed("left_click"):
		shoot.emit()

func _on_health_engine_took_damage(new_health: float):
	update_hud_health(new_health)

func update_hud_health(new_health: float):
	var hud: HUD = get_tree().get_first_node_in_group("HUD")
	
	# If the hud was not loaded.
	if not hud:
		push_error("The player can not load the hud!")
		
	hud.update_player_health(new_health)

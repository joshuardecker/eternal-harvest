extends Node2D

## A universal health node that tracks and modifies health.
## Very versatile and can be used for any create, including the player.
## All variables are configurable, and signals are sent out when important
## events happen.
class_name HealthEngine

@export var health: float = 1
## Each armor is a 1% damage reduction.
@export_range(0,100) var armor: float

## What percent should this be healing per second of the initial health?
@export_range(1, 100) var heal_modifier: float

signal is_dead
signal took_damage(new_health: float)
signal is_healing
signal is_done_healing(new_health: float)

# The initial health becomes the max health.
var max_health: float

# A timer to keep track of how long this engine heals itself.
# Isnt doing anything when its not healing.
var heal_timer = Timer.new()

# Every health component will look for a hitbox to connect to.
var hitbox: Hitbox = null

func _ready():
	var parent = get_parent()
	
	# Loop through the siblings to see if there is a hitbox.
	for child in parent.get_children():
		if child is Hitbox:
			hitbox = child
	
	# If the hitbox is not found.
	if not hitbox:
		push_error(parent, " does not have a hitbox and needs one!")
		
	# When something enters the hitbox, it may be another hitbox attempting
	# to damage it. So the health engine connects these funcs.
	hitbox.connect("area_entered", take_damage)
	
	max_health = health
	
	# Simple scene setup for the timer.
	add_child(heal_timer)
	
	heal_timer.autostart = false
	heal_timer.one_shot = true
	heal_timer.connect("timeout", done_healing)

func _physics_process(delta):
	# If the heal timer running, this needs to heal.
	# So it heals every frame until the timer is done.
	if !heal_timer.is_stopped():
		heal(max_health * (heal_modifier / 100) * delta)

func take_damage(area: Area2D):
	# If the area is not a hitbox.
	if not (area is Hitbox):
		return
	
	# Area is known to be a hitbox, so the damage field exists.
	health -= area.damage * (1 - (armor / 100))
	
	if health <= 0:
		is_dead.emit()
	
	took_damage.emit(health)
	
func heal(amount: float):
	health += amount
	
	is_healing.emit()

func start_healing(duration: float):
	heal_timer.start(duration)
	
	is_healing.emit()

func done_healing():
	is_done_healing.emit(health)

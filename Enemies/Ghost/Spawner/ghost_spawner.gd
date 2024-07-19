extends Node2D

## A simple node that can be placed around the map to spawn in ghosts.
class_name GhostSpawner

## When a new wave starts, this sends out a signal.
## Useful for things like the HUD that keep track of this.
signal next_wave_started

## The time between spawning new waves
@export var wave_time_length: float = 5

var timer = Timer.new()

func _ready():
	# All stuff that sets up the timer:
	add_child(timer)
	
	timer.autostart = false
	timer.one_shot = false
	timer.connect("timeout", spawn_wave)

# This func is called by the entity manager itself, that way it is known
# that the entity manager exists.
# Used only to allow the ghost spawner to spawn ghosts with the 
# entity manager, rather than on its own.
func load_entity_manager():
	var entity_manager = get_tree().get_first_node_in_group("EntityManager")
	
	connect("next_wave_started", entity_manager.load_ghost.bind(global_position))

func start():
	# When the timer starts, waves start.
	timer.start(wave_time_length)

func stop():
	# When the timer stops, no more waves spawn.
	timer.stop()

func spawn_wave():
	next_wave_started.emit()

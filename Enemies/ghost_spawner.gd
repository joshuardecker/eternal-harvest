extends Node2D

## A simple node that can be placed around the map to spawn in ghosts.
class_name GhostSpawner

## The time between spawning new waves
@export var wave_time_length: float = 5

## When a new wave starts, this sends out a signal.
## Useful for things like the HUD that keep track of this.
signal next_wave_started

var timer = Timer.new()

var ghost: PackedScene = load("res://Enemies/ghost.tscn")

func _ready():
	# All stuff that sets up the timer:
	add_child(timer)
	
	timer.autostart = false
	timer.one_shot = false
	timer.connect("timeout", spawn_wave)

func start():
	# When the timer starts, waves start.
	timer.start(wave_time_length)

func stop():
	# When the timer stops, no more waves spawn.
	timer.stop()

func spawn_wave():
	var new_ghost: Ghost = ghost.instantiate()
	new_ghost.global_position = self.global_position
	get_tree().root.add_child(new_ghost)
	
	next_wave_started.emit()

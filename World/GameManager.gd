extends Node2D

## The head honcho of the game. Manages respawning the player, displaying
## the correct visual layers (HUD, main menu, ect).
## Only one of these should exist at a time.
class_name GameManager

@onready var player_scene: PackedScene = preload("res://Player/player.tscn")
@onready var hud_scene: PackedScene = preload("res://HUD/hud.tscn")

const PLAYER_STARTING_POS = Vector2(150, 60)

var ghost_spawners: Array[Node]
var player: Player
var hud: HUD

func _ready():
	call_deferred("start_game")

func spawn_player():
	player = player_scene.instantiate()
	
	player.global_position = PLAYER_STARTING_POS
	get_tree().root.add_child(player)

func _unhandled_key_input(_event):
	if Input.is_action_pressed("escape"):
		get_tree().quit()

func start_game():
	spawn_player()
	
	ghost_spawners = get_tree().get_nodes_in_group("GhostSpawner")
	
	for spawner in ghost_spawners:
		spawner.start()
		
	# Load the hud.
	hud = hud_scene.instantiate()
	get_tree().root.add_child(hud)
		
func stop_game():
	for spawner in ghost_spawners:
		spawner.stop()
		
	# Remove the hud.
	get_tree().root.remove_child(hud)
	
	# Removes the player.
	get_tree().root.remove_child(player)
	player.queue_free()

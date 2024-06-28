extends Node2D

## The head honcho of the game. Manages respawning the player, displaying
## the correct visual layers (HUD, main menu, ect).
## Only one of these should exist at a time.
class_name GameManager

@onready var player_scene: PackedScene = preload("res://Player/player.tscn")
@onready var hud_scene: PackedScene = preload("res://HUD/hud.tscn")
@onready var main_menu_scene: PackedScene = preload("res://HUD/main_menu.tscn")

const PLAYER_STARTING_POS = Vector2(150, 60)

var ghost_spawners: Array[Node]
var player: Player
var main_menu: MainMenu
var hud: HUD

func _ready():
	call_deferred("load_main_menu")

func _unhandled_key_input(_event):
	if Input.is_action_pressed("escape"):
		quit_game()

func quit_game():
	get_tree().quit()

# Should be the first function run to start the game by the game manager.
func load_main_menu():
	main_menu = main_menu_scene.instantiate()
	
	get_tree().root.add_child(main_menu)
	
	main_menu.connect("start", start_game)
	main_menu.connect("exit", quit_game)

func start_game():
	# Spawn the player.
	player = player_scene.instantiate()
	player.global_position = PLAYER_STARTING_POS
	get_tree().root.add_child(player)
	
	# Start the ghost spawners.
	ghost_spawners = get_tree().get_nodes_in_group("GhostSpawner")
	for spawner in ghost_spawners:
		spawner.start()
		
	# Load the hud.
	hud = hud_scene.instantiate()
	get_tree().root.add_child(hud)
	
	# Removes the main menu.
	get_tree().root.remove_child(main_menu)
	main_menu.queue_free()
	
func stop_game():
	# Stop all the ghost spawners.
	for spawner in ghost_spawners:
		spawner.stop()
		
	# Remove the hud.
	get_tree().root.remove_child(hud)
	hud.queue_free()
	
	# Removes the player.
	get_tree().root.remove_child(player)
	player.queue_free()

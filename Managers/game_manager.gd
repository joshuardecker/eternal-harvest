extends Node2D

## The head honcho of the game. Manages respawning the player, displaying
## the correct visual layers (HUD, main menu, ect).
## Only one of these should exist at a time.
class_name GameManager

@onready var ui_manager_scene: PackedScene = preload("res://Managers/ui_manager.tscn")

@onready var player_scene: PackedScene = preload("res://Player/player.tscn")

const PLAYER_STARTING_POS = Vector2(150, 60)

# Various managers:
var ui_manager: UIManager

var ghost_spawners: Array[GhostSpawner]
var player: Player

func _ready():
	# Both have to be call defered since this is happening as soon as the game 
	# starts. Much is going on loading wise at this time, so lets wait till
	# its done before we load these things.
	call_deferred("load_ui_manager")
	call_deferred("load_main_menu")
	
func _unhandled_key_input(_event):
	if Input.is_action_pressed("escape"):
		quit_game()
	
# Load and add the UI manager to the scene.
func load_ui_manager():
	ui_manager = ui_manager_scene.instantiate()
	get_tree().root.add_child(ui_manager)

func load_main_menu():
	ui_manager.load_main_menu()

func start_game():
	# Spawn the player.
	player = player_scene.instantiate()
	player.global_position = PLAYER_STARTING_POS
	get_tree().root.add_child(player)
	
	# Any node in the GhostSpawner group we know is a GhostSpawner class.
	# However, this is not technically guaranteed at compile time, so
	# we have to do a runtime check and convert the technically unknown nodes
	# into known GhostSpawners. This is done because a runtime check guarantees
	# safety.
	var hopefully_spawners: Array[Node] = get_tree().get_nodes_in_group("GhostSpawner")
	
	for potensial_spawner in hopefully_spawners:
		if potensial_spawner is GhostSpawner:
			ghost_spawners.append(potensial_spawner)
		else:
			push_error("A not ghost spawner is in the ghost spawner group!")
	
	# Loop through the checked spawners and start them spawning!
	for spawner in ghost_spawners:
		spawner.start()
	
	# Edit the UI.
	ui_manager.load_hud()
	ui_manager.unload_main_menu()

func stop_game():
	# Stop all the ghost spawners.
	for spawner in ghost_spawners:
		spawner.stop()
		
	# Edit the UI.
	ui_manager.unload_hud()
	
	# Removes the player.
	get_tree().root.remove_child(player)
	player.queue_free()

func quit_game():
	get_tree().quit()
	
# TODO: move to the settings manager
func change_fullscreen(enabled: bool):
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
# TODO: move to settings manager
# The settings menu automatically sends the correct mode as an int.
func change_vsync_mode(mode: int):
	DisplayServer.window_set_vsync_mode(mode)

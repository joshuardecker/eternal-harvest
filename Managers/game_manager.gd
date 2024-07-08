extends Node2D

## The head honcho of the game. Manages respawning the player, displaying
## the correct visual layers (HUD, main menu, ect).
## Only one of these should exist at a time.
class_name GameManager

@onready var ui_manager_scene: PackedScene = preload("res://Managers/ui_manager.tscn")
@onready var entity_manager_scene: PackedScene = preload("res://Managers/entity_manager.tscn")
@onready var settings_manager_scene: PackedScene = preload("res://Managers/settings_manager.tscn")

const PLAYER_STARTING_POS = Vector2(155, 65)

# Various managers:
var ui_manager: UIManager
var entity_manager: EntityManager
var settings_manager: SettingsManager

func _ready():
	# Wait for the first frame to have occured.
	# If it has, that means the game is done initializing and one can
	# safely start adding nodes to the scene tree without worry of
	# it being busy and not being able too.
	await get_tree().process_frame
	
	# Load the managers.
	ui_manager = load_ui_manager()
	entity_manager = load_entity_manager()
	settings_manager = load_settings_manager()
	
	ui_manager.load_main_menu()
	
func _unhandled_key_input(_event):
	if Input.is_action_pressed("escape"):
		stop_game()
		ui_manager.load_main_menu()
	
# Load and add the UI manager to the scene.
func load_ui_manager() -> UIManager:
	var new_manager: UIManager = ui_manager_scene.instantiate()
	
	get_tree().root.add_child(new_manager)
	
	return new_manager

func load_entity_manager() -> EntityManager:
	var new_manager: EntityManager = entity_manager_scene.instantiate()
	
	get_tree().root.add_child(new_manager)
	
	return new_manager

func load_settings_manager() -> SettingsManager:
	var new_manager: SettingsManager = settings_manager_scene.instantiate()
	
	get_tree().root.add_child(new_manager)
	
	return new_manager

func start_game():
	# Spawn the player.
	entity_manager.load_player(PLAYER_STARTING_POS)
	
	# Load and activate all of the ghost spawners.
	entity_manager.load_ghost_spawners()
	
	# Edit the UI.
	ui_manager.load_hud()
	ui_manager.unload_main_menu()

func stop_game():
	# Unloads all entities and stops all ghost spawners.
	entity_manager.despawn_all()
	
	# Edit the UI.
	ui_manager.unload_hud()

func quit_game():
	get_tree().quit()

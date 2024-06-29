extends Node2D

## A class that manages the various UIs of the game.
## Custom functions will handle each UI, ex: main menu, settings menu, ect
## because each menu will need buttons connected to stuff.
## This class exists to make the GameManagers life easier and simplier.
class_name UIManager

# A list of all of the UIs, each one will need a corresponding func:

var main_menu_scene: PackedScene = load("res://UI/main_menu.tscn")
var main_menu: MainMenu

@onready var settings_menu_scene: PackedScene = load("res://UI/settings_menu.tscn")
var settings_menu: SettingsMenu

@onready var hud_scene: PackedScene = load("res://UI/hud.tscn")
var hud: HUD

# We need to know the game manager because when UI elements are clicked, the 
# game manager needs to know. This UI manager does not care if a button is pressed,
# its only here to display stuff.
var game_manager: GameManager

func _ready():
	# Get the game manager.
	game_manager = get_tree().get_first_node_in_group("GameManager")
	
	# If it did not find the game manager.
	if not game_manager:
		push_error("The UI manager could not find the GameManager!")

func load_main_menu():
	main_menu = main_menu_scene.instantiate()
	get_tree().root.add_child(main_menu)
	
	# Connects the main menu buttons to their functions.
	main_menu.connect("start", game_manager.start_game)
	main_menu.connect("settings", load_settings_menu)
	main_menu.connect("exit", game_manager.quit_game)
	
func unload_main_menu():
	get_tree().root.remove_child(main_menu)
	main_menu.queue_free()
	
func load_settings_menu():
	# Since the settings menu comes from the main menu, deal with that here.
	unload_main_menu()
	
	settings_menu = settings_menu_scene.instantiate()
	get_tree().root.add_child(settings_menu)
	
	# Connect useful settings functions.
	settings_menu.connect("fullscreen", game_manager.change_fullscreen)
	settings_menu.connect("vsync_mode", game_manager.change_vsync_mode)
	settings_menu.connect("back", unload_settings_menu)
	
func unload_settings_menu():
	get_tree().root.remove_child(settings_menu)
	settings_menu.queue_free()
	
	# Go back to the main menu.
	load_main_menu()
	
func load_hud():
	hud = hud_scene.instantiate()
	get_tree().root.add_child(hud)
	
func unload_hud():
	get_tree().root.remove_child(hud)
	hud.queue_free()

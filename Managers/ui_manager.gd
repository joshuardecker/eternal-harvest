extends Node2D

## A class that manages the various UIs of the game.
## Custom functions will handle each UI, ex: main menu, settings menu, ect
## because each menu will need buttons connected to stuff.
## This class exists to make the GameManagers life easier and simplier.
class_name UIManager

# A list of all of the UIs, each one will need a corresponding func:

var main_menu_scene: PackedScene = load("res://UI/main_menu.tscn")
var main_menu: MainMenu

@onready var settings_menu_scene: PackedScene = load("") # TODO: when settings is made, add here
var settings_menu: Node # TODO: fix as well

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
	main_menu.connect("exit", game_manager.quit_game)
	
func unload_main_menu():
	get_tree().root.remove_child(main_menu)
	main_menu.queue_free()
	
func load_settings_menu():
	pass
	
func unload_settings_menu():
	pass
	
func load_hud():
	hud = hud_scene.instantiate()
	get_tree().root.add_child(hud)
	
func unload_hud():
	get_tree().root.remove_child(hud)
	hud.queue_free()

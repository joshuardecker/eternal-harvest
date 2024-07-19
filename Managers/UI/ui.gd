extends CanvasLayer

## A class that manages the various UIs of the game.
## Custom functions will handle each UI, ex: main menu, settings menu, ect
## because each menu will need buttons connected to stuff.
## This class exists to make the GameManagers life easier and simplier.
class_name UIManager

# A list of all of the UIs, each one will need a corresponding func:

var main_menu_scene: PackedScene = load("res://UI/MainMenu/main_menu.tscn")
var main_menu: MainMenu

var settings_menu_scene: PackedScene = load("res://UI/Settings/settings.tscn")
var settings_menu: SettingsMenu

var hud_scene: PackedScene = load("res://UI/Hud/hud.tscn")
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

# The ui manager itself is a canvas layer, so adding any ui as a child
# to the ui manager makes the ui drawn on a canvas layer.
func push_to_canvas(ui):
	add_child(ui)

func remove_from_canvas(ui):
	for child in get_children():
		if child == ui:
			remove_child(child)
			child.queue_free()

func load_main_menu():
	main_menu = main_menu_scene.instantiate()
	push_to_canvas(main_menu)
	
	# Connects the main menu buttons to their functions.
	main_menu.connect("start", game_manager.start_game)
	main_menu.connect("settings", load_settings_menu)
	main_menu.connect("exit", game_manager.quit_game)
	
func unload_main_menu():
	remove_from_canvas(main_menu)
	
func load_settings_menu():
	# Since the settings menu comes from the main menu, deal with that here.
	unload_main_menu()
	
	settings_menu = settings_menu_scene.instantiate()
	push_to_canvas(settings_menu)

func unload_settings_menu():
	remove_from_canvas(settings_menu)
	
	# Go back to the main menu.
	load_main_menu()
	
func load_hud():
	hud = hud_scene.instantiate()
	push_to_canvas(hud)
	
func unload_hud():
	remove_from_canvas(hud)

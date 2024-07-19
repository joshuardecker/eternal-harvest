extends Node

## This is where the game starts.
## This node simply loads the world scene and the game manager.
class_name Start

var world_scene: PackedScene = preload("res://World/world.tscn")
var game_manager_scene: PackedScene = preload("res://Managers/Game/game.tscn")

func _ready():
	# Load the world and game manager.
	var world = world_scene.instantiate()
	var game_manager = game_manager_scene.instantiate()
	
	# Wait for the first frame to have occured.
	# If it has, that means the game is done initializing and one can
	# safely start adding nodes to the scene tree without worry of
	# it being busy and not being able too.
	await get_tree().process_frame
	
	# Add the world and game manager to the scene.
	get_tree().root.add_child(world)
	get_tree().root.add_child(game_manager)

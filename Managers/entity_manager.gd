extends Node2D

## Manages spawning and despawning of entities in the game world.
## Example: the player, ghosts, ghost spawners, etc.
class_name EntityManager

@onready var player_scene: PackedScene = load("res://Player/player.tscn")
@onready var ghost_scene: PackedScene = load("res://Enemies/ghost.tscn")

var player: Player
var ghosts: Array[Ghost]
var ghost_spawners: Array[GhostSpawner]

var world: Node2D

func _ready():
	world = load_world()
	
# Loads the world node so childen can be added to it by the entity manager.
func load_world() -> Node2D:
	var potentially_world = get_tree().get_first_node_in_group("World")
	
	# If the world node was not found.
	if not potentially_world:
		push_error("Entity manager could not load the world!")
	
	return potentially_world

# Loads a new instance of the player.
# Assumes that the load_world func has already been called.
func load_player(global_pos: Vector2) -> Player:
	# If the world is not loaded into the world var. 
	if not world:
		push_error("Entity manager tried to load the player
but the world hasnt been loaded!")
	
	player = player_scene.instantiate()
	
	# Add the player to the currect location in the world scene.
	player.global_position = global_pos
	world.add_child(player)
	
	return player

func despawn_player():
	# If the player does not exist.
	if not player:
		return
		
	world.remove_child(player)
	player.queue_free()

func load_ghost(global_pos: Vector2) -> Ghost:
	# If the world is not loaded into the world var. 
	if not world:
		push_error("Entity manager tried to load a ghost
but the world hasnt been loaded!")
	
	var ghost: Ghost = ghost_scene.instantiate()
		
	# Adds a ghost to the world scene.
	ghost.global_position = global_pos
	world.add_child(ghost)
	
	# Need to remember this ghost.
	ghosts.append(ghost)
	
	return ghost
	
func despawn_ghost(ghost: Ghost):
	# If the ghost does not exist.
	if not ghost:
		return
		
	# Removes the ghost from the array.
	# If its not found, nothing happens.
	ghosts.erase(ghost)
	
	world.remove_child(ghost)
	ghost.queue_free()
	
# Ghost spawners are assumed to already be hand placed around the world.
# No loading from a file, just finding them in the scene tree.
# Also loading the ghost spawners activates them.
func load_ghost_spawners() -> Array[GhostSpawner]:
	# If the world does not exist.
	if not world:
		push_error("Entity manager tried to load ghost spawners
but the world hasnt been loaded!")
	
	# Get the spawners from the world scene.
	var spawners = get_tree().get_nodes_in_group("GhostSpawner")
	
	# Loop through each node in the GhostSpawner group and do a 
	# runtime check if they are the correct type. 
	# If so, save them for later.
	for spawner in spawners:
		if spawner is GhostSpawner:
			ghost_spawners.append(spawner)
			
	# Loop through and start the ghost spawners spawning.
	for spawner in ghost_spawners:
		spawner.load_entity_manager()
		spawner.start()
			
	return ghost_spawners

# Despawns all entities known to the entity manager.
# Also deactivates all of the ghost spawners.
func despawn_all():
	while ghosts.size() > 0:
		var ghost: Ghost = ghosts.pop_back()
		ghost.despawn()
	
	# Turn off all of the spawners.
	for spawner in ghost_spawners:
		spawner.stop()
		
	for ghost_spawner in ghost_spawners:
		ghost_spawner.disconnect("next_wave_started", load_ghost)
	
	# Clear the array so that when they are loaded again,
	# there are no duplicates.
	ghost_spawners.clear()
	
	despawn_player()

extends Node2D

## A simple manager that remembers stats of important entities.
## Examples of important entities are the player and any bosses.
class_name StatsManager

# Signals useful for the hud to hook to.
signal new_player_score(score: int)
signal new_player_health(new_health: float)
signal new_player_currency(new_currency: int)

const PLAYER_START_HEALTH: float = 100

# Player stats:
var player_kills: int
var player_score: int
# Note the player only copies its health here, it still stores it locally.
var player_health: float
var player_currency: int

var game_manager: GameManager

func _ready():
	game_manager = get_tree().get_first_node_in_group("GameManager")
	
	# If the game manager was not found.
	if not game_manager:
		push_error("The stats manager could not load the game manager!")

func reset():
	player_kills = 0
	player_score = 0
	player_health = PLAYER_START_HEALTH
	player_currency = 0

# Increase the player kills by one.
func update_player_kills():
	player_kills += 1
	
	# 1 kill is worth 10 points.
	update_player_score(10)

func update_player_score(points: int):
	player_score += points
	new_player_score.emit(points)
	
func update_player_health(new_health: float):
	player_health = new_health
	new_player_health.emit(player_health)
	
	if player_health <= 0:
		game_manager.call_deferred("stop_game")
	
# Amount can be negative.
# Allows for the player to gain or lose currency.
func update_player_currency(amount: int):
	player_currency += amount
	new_player_currency.emit(player_currency)

extends Control

## The basic display of useful information to the user.
class_name HUD

@onready var wave_num_label = $CenterContainer/HBoxContainer/WaveNumber
@onready var player_health_label = $CenterContainer/HBoxContainer/PlayerHealth
@onready var score_label = $CenterContainer/HBoxContainer/Score

var wave_num: int = 0
var score: int = 0

var stats_manager: StatsManager

func _ready():
	stats_manager = get_tree().get_first_node_in_group("StatsManager")
	
	# If the stats manager could not be loaded.
	if not stats_manager:
		push_error("The HUD could not find the stats manager!")
		
	stats_manager.connect("new_player_score", update_score)
	stats_manager.connect("new_player_health", update_player_health)
	# TODO: add currency part to hud
	#stats_manager.connect("new_player_currency")
	
	# Load a ghost spawner, that way the hud has a source of information
	# of when the next wave has spawned.
	var some_spawner = get_tree().get_first_node_in_group("GhostSpawner")
	
	# If a ghost spawner could not be found.
	if not some_spawner:
		push_error("The HUD could not load a ghost spawner!")
		
	some_spawner.connect("next_wave_started", update_wave_num)

# Increases the displayed wave number by 1.
func update_wave_num():
	wave_num += 1
	wave_num_label.text = "Wave: " + str(wave_num)
	
func update_player_health(amount: float):
	player_health_label.text = "Health: " + str(floor(amount))
	
# Increases the displayed kill counter by 1.
func update_score(amount: int):
	score = amount
	score_label.text = "Score: " + str(score)
	
# Full reset of whats saved and displayed.
func reset():
	wave_num = 0
	score = 0
	
	wave_num_label.text = "Wave: Soon!"
	player_health_label.text = "Health: 100"
	score_label.text = "Score: 0"

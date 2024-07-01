extends Control

## The basic display of useful information to the user.
class_name HUD

@onready var wave_num_label = $CenterContainer/HBoxContainer/WaveNumber
@onready var player_health_label = $CenterContainer/HBoxContainer/PlayerHealth
@onready var kill_amount_label = $CenterContainer/HBoxContainer/KillAmount

var wave_num: int = 0
var kill_amount: int = 0

func _ready():
	# Load a ghost spawner, that way the hud has a source of information
	# of when the next wave has spawned.
	var some_spawner = get_tree().get_first_node_in_group("GhostSpawner")
	
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
func update_kill_amount():
	kill_amount += 1
	kill_amount_label.text = "Kills: " + str(kill_amount)
	
# Full reset of whats saved and displayed.
func reset():
	wave_num = 0
	kill_amount = 0
	
	wave_num_label.text = "Wave: Soon!"
	player_health_label.text = "Health: 100"
	kill_amount_label.text = "Kills: 0"

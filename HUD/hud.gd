extends Control

## The basic display of useful information to the user.
class_name HUD

@onready var wave_num_label = $CenterContainer/HBoxContainer/WaveNumber
@onready var player_health_label = $CenterContainer/HBoxContainer/PlayerHealth
@onready var kill_amount_label = $CenterContainer/HBoxContainer/KillAmount

var wave_num: int = 0
var health: float = 100
var kill_amount: int = 0

# Increases the displayed wave number by 1.
func update_wave_num():
	wave_num += 1
	wave_num_label.text = "Wave: " + str(wave_num)
	
func update_player_health(amount: float):
	health -= amount
	player_health_label.text = "Health: " + str(floor(health))
	
# Increases the displayed kill counter by 1.
func update_kill_amount():
	kill_amount += 1
	kill_amount_label.text = "Kills: " + str(kill_amount)
	
# Full reset of whats saved and displayed.
func reset():
	wave_num = 0
	health = 100
	kill_amount = 0
	
	wave_num_label.text = "Wave: Soon!"
	player_health_label.text = "Health: 100"
	kill_amount_label.text = "Kills: 0"

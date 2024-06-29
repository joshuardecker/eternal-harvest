extends Control

## The main menu of the game. Only should be one at a time. Can be spawned
## and deleted as much as needed. Settings are saved elsewhere.
class_name MainMenu

signal start
signal settings
signal exit

func _on_start_pressed():
	start.emit()

func _on_settings_pressed():
	settings.emit()

func _on_exit_pressed():
	exit.emit()

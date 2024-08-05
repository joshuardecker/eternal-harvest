extends Control

## The main menu of the game. Only should be one at a time. Can be spawned
## and deleted as much as needed. Settings are saved elsewhere.
class_name MainMenu

signal start
signal settings
signal exit

# Load this to get its initial y coord.
# That way if I move it in the editor,
# I dont have to change the code.
@onready var game_title: CenterContainer = $CenterContainer
@onready var button_hover: AudioStreamPlayer = $ButtonHover

var y_cord: float
var internal_timer: float

func _on_start_pressed():
	start.emit()

func _on_settings_pressed():
	settings.emit()

func _on_exit_pressed():
	exit.emit()

func _on_start_mouse_entered():
	button_hover.play()

func _on_settings_mouse_entered():
	button_hover.play()

func _on_exit_mouse_entered():
	button_hover.play()

func _ready():
	y_cord = game_title.global_position.y

func _process(delta: float):
	internal_timer += delta
	
	game_title.global_position.y = y_cord + custom_sin(internal_timer)

func custom_sin(num: float) -> float:
	return sin(num) * 15

extends Control

class_name SettingsMenu

signal fullscreen(bool)
signal vsync_mode(int)
signal back

@onready var fullscreen_button = $CenterContainer2/VBoxContainer/Fullscreen
@onready var vsync_button = $CenterContainer2/VBoxContainer/VSync
@onready var back_button = $CenterContainer2/VBoxContainer/Back

#TODO: when the settings manager is added, have the settings menu connect signals there itself.

func _on_fullscreen_pressed():
	if fullscreen_button.button_pressed:
		fullscreen.emit(true)
	else:
		fullscreen.emit(false)

func _on_v_sync_item_selected(index):
	# I can just emit the index of the option chosen because those indexes
	# purposefully match the value of the vsync setting. So if the index is 0,
	# the vsync mode that needs to be set is 0.
	vsync_mode.emit(index)

func _on_back_pressed():
	back.emit()

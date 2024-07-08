extends Node2D

# A manager to configure and remember the players settings.
class_name SettingsManager

const SAVE_FILE_NAME: String = "settings.cfg"
# The config file requires stats to be organised by sections.
# This game only has one player, so everything is saved under
# the 'Player' section.
const SECTION: String = "Player"

#====#
# Settings to remember:
var fullscreen: bool = true

enum vsync_modes { ENABLED, DISABLED }
var current_vsync = vsync_modes.ENABLED
#====#

func _ready():
	var error = load_settings_from_file()
	
	# If the cfg could not be loaded, save a new copy to the disk.
	# No need to reload because it just saves the default settings already 
	# stored in memory.
	if error != OK:
		save_settings_to_file()
	
	apply_settings()

func load_settings_from_file() -> Error:
	var cfg: ConfigFile = ConfigFile.new()
	
	var error = cfg.load(SAVE_FILE_NAME)
	
	# If there was an error loading the file.
	if error != OK:
		return error
	
	# Get all of the stored values from the file.
	fullscreen = cfg.get_value(SECTION, "fullscreen")
	current_vsync = cfg.get_value(SECTION, "current_vsync")
	
	return OK

func save_settings_to_file():
	var new_cfg: ConfigFile = ConfigFile.new()
	
	# Write all of the default values to the config file.
	new_cfg.set_value(SECTION, "fullscreen", fullscreen)
	new_cfg.set_value(SECTION, "current_vsync", current_vsync)
	
	new_cfg.save(SAVE_FILE_NAME)

func apply_settings():
	# Apply fullscreen settings:
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		
	# Apply the vsync preferance.
	if current_vsync == vsync_modes.ENABLED:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

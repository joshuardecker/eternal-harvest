extends Control

class_name SettingsMenu

signal back

@onready var fullscreen_button = $CenterContainer2/VBoxContainer/Fullscreen
@onready var vsync_button = $CenterContainer2/VBoxContainer/VSync
@onready var back_button = $CenterContainer2/VBoxContainer/Back
@onready var button_hover: AudioStreamPlayer = $ButtonHover
@onready var settings_title = $CenterContainer

# Needs this to tell the UI manager when to return back to the main menu.
var ui_manager: UIManager
var settings_manager: SettingsManager

var y_cord: float
var internal_timer: float

func _ready():
	# Load the nessesary managers.
	ui_manager = load_ui_manager()
	settings_manager = load_settings_manager()
	
	load_settings()
	
	y_cord = settings_title.global_position.y

func _on_fullscreen_pressed():
	settings_manager.fullscreen = fullscreen_button.button_pressed
	
	settings_manager.apply_settings()

func _on_v_sync_item_selected(index):
	# If vsync off is selected.
	if index == 0:
		settings_manager.current_vsync = settings_manager.vsync_modes.DISABLED
	# If vsync on is selected.
	else:
		settings_manager.current_vsync = settings_manager.vsync_modes.ENABLED
		
	settings_manager.apply_settings()

func _on_back_pressed():
	# Since we are leaving the settings menu, now is a good time to save the
	# new settings to the file.
	settings_manager.save_settings_to_file()
	
	ui_manager.unload_settings_menu()

func load_ui_manager() -> UIManager:
	var manager: UIManager = get_tree().get_first_node_in_group("UIManager")
	
	# If the settings manager is not loaded.
	if not manager:
		push_error("The settings menu could not find the UIManager!")
		
	return manager

func load_settings_manager() -> SettingsManager:
	var manager: SettingsManager = get_tree().get_first_node_in_group("SettingsManager")
	
	# If the settings manager is not loaded.
	if not manager:
		push_error("The settings menu could not find the SettingsManager!")
		
	return manager

# Load the settings, that way the menu displays what is currently set.
func load_settings():
	fullscreen_button.button_pressed = settings_manager.fullscreen
	
	# If vsync is enabled, have that button selected in the settings.
	if settings_manager.current_vsync == settings_manager.vsync_modes.ENABLED:
		vsync_button.selected = 1
	# Vsync is disabled, so have that button selected in the settings.
	else:
		vsync_button.selected = 0

func _on_v_sync_mouse_entered():
	button_hover.play()

func _on_back_mouse_entered():
	button_hover.play()

func _process(delta):
	internal_timer += delta
	
	settings_title.global_position.y = y_cord + custom_sin(internal_timer)
	
func custom_sin(num: float) -> float:
	return sin(num) * 20

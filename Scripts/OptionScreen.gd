extends CenterContainer

#region Variables
@onready var menu_controller = $"../../MenuController"
@onready var slider_volume = $VBoxContainer/HBox_Board_Size/Slider_Volume
@onready var option_language = $VBoxContainer/HBox_Language/Option_Language
#endregion

#region Function: script start
func _ready():
	# set up controls in option screen
	set_up_option_controls()
#endregion

#region Signal: Back button pressed signal
func _on_btn_back_pressed():
	menu_controller.change_menu(Constants.MenuPage.MainMenu)
#endregion

#region Signal: called when volume slider value changed
func _on_slider_volume_value_changed(_value):
	# When adjusting the volume, immediately call the save function to apply the volume
	save_option()
#endregion

#region Signal: language select signal
func _on_option_language_item_selected(index):
	match index:
		0:
			TranslationServer.set_locale("en")
		1:
			TranslationServer.set_locale("kr")
	save_option()
#endregion

#region Function: A function that sets the controls in an option to values read from the settings file
# reference for volume change: https://docs.godotengine.org/en/stable/classes/class_audioserver.html#class-audioserver-method-get-bus-index
func set_up_option_controls():	
	var config = ConfigFile.new()
	var err = config.load("res://Config.cfg")
	
	if err != OK:
		return
	
	# set master volume
	var volume = config.get_value("Option", "Volume")
	slider_volume.value = volume
	var audio_bus_index = AudioServer.get_bus_index("Master")
	var volume_db = linear_to_db(slider_volume.value)
	AudioServer.set_bus_volume_db(audio_bus_index, volume_db)
	
	# language
	var langCode = config.get_value("Option", "Language")
	match langCode:
		"en": option_language.selected = 0
		"kr": option_language.selected = 1
#endregion

#region Function: save config
func save_option():
	var config = ConfigFile.new()
	var err = config.load("res://Config.cfg")
	
	if err != OK:
		return
	
	# set master volume
	var audio_bus_index = AudioServer.get_bus_index("Master")
	var volume_db = linear_to_db(slider_volume.value)
	AudioServer.set_bus_volume_db(audio_bus_index, volume_db)
	
	config.set_value("Option", "Volume", slider_volume.value)
	config.set_value("Option", "Language", TranslationServer.get_locale())
	config.save("res://Config.cfg")
#endregion

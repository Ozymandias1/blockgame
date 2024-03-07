extends Node

#region Function: script start
func _ready():
	check_config_file() # check config when script started
#endregion

#region Function: Function to check if there is a setting file
# check that there is a configuration file in the target path,
# and if there is no configuration file, create the configuration file specified by default.
func check_config_file():
	var config = ConfigFile.new()
	var err = config.load("res://Config.cfg")
	if err != OK:
		create_default_config_file()
	else:
		# If there is a configuration file, take the language configuration and process it.
		var langCode = config.get_value("Option", "Language")
		TranslationServer.set_locale(langCode)
#endregion

#region Function: create default setting configuration file
func create_default_config_file():
	var config = ConfigFile.new()
	config.set_value("Option", "Volume", 100)
	config.set_value("Option", "Language", "en")
	config.save("res://Config.cfg")
#endregion

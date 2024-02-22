extends Node

# 스크립트 시작
func _ready():
	check_config_file() # 시작시 설정파일 확인

# 지정된 경로에 설정파일이 있는지 확인하고
# 설정파일이 없으면 기본값으로 지정된 설정파일을 생성한다.
func check_config_file():
	var config = ConfigFile.new()
	var err = config.load("res://Config.cfg")
	if err != OK:
		create_default_config_file()
	else:
		# 설정파일이 있다면 언어설정값을 가져와 처리한다.
		var langCode = config.get_value("Option", "Language")
		TranslationServer.set_locale(langCode)

# 기본값으로 지정된 설정파일을 생성하는 함수
func create_default_config_file():
	var config = ConfigFile.new()
	config.set_value("Option", "Volume", 100)
	config.set_value("Option", "Language", "en")
	config.save("res://Config.cfg")

extends CenterContainer

@onready var menu_controller = $"../../MenuController"
@onready var slider_volume = $VBoxContainer/HBox_Board_Size/Slider_Volume
@onready var option_language = $VBoxContainer/HBox_Language/Option_Language

# 스크립트 시작
func _ready():
	set_up_option_controls()

# Back 버튼 클릭 시그널
func _on_btn_back_pressed():
	menu_controller.change_menu(Constants.MenuPage.MainMenu)

# 볼륨 조절 슬라이더 값변화 시그널
func _on_slider_volume_value_changed(value):
	save_option()
	
# 언어 옵션 항목 선택 시그널
func _on_option_language_item_selected(index):
	match index:
		0:
			TranslationServer.set_locale("en")
		1:
			TranslationServer.set_locale("kr")
	save_option()

# 옵션내 컨트롤들을 설정파일에서 읽어들인 값으로 세팅하는 함수
# 볼륨 설정 참고: https://docs.godotengine.org/en/stable/classes/class_audioserver.html#class-audioserver-method-get-bus-index
func set_up_option_controls():	
	var config = ConfigFile.new()
	var err = config.load("res://Config.cfg")
	
	if err != OK:
		return
	
	# 볼륨
	# 마스터 볼륨 설정
	var volume = config.get_value("Option", "Volume")
	slider_volume.value = volume
	var audio_bus_index = AudioServer.get_bus_index("Master")
	var volume_db = linear_to_db(slider_volume.value)
	AudioServer.set_bus_volume_db(audio_bus_index, volume_db)
	
	# 언어
	var langCode = config.get_value("Option", "Language")
	match langCode:
		"en": option_language.selected = 0
		"kr": option_language.selected = 1

# 옵션 저장
func save_option():
	var config = ConfigFile.new()
	var err = config.load("res://Config.cfg")
	
	if err != OK:
		return
	
	# 마스터 볼륨 설정
	var audio_bus_index = AudioServer.get_bus_index("Master")
	var volume_db = linear_to_db(slider_volume.value)
	AudioServer.set_bus_volume_db(audio_bus_index, volume_db)
	
	config.set_value("Option", "Volume", slider_volume.value)
	config.set_value("Option", "Language", TranslationServer.get_locale())
	config.save("res://Config.cfg")

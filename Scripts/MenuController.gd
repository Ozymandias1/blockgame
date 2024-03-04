extends Node

@onready var main_menu = $"../MenuList/MainMenu"
@onready var set_game_condition = $"../MenuList/SetGameCondition"
@onready var gameplay = $"../MenuList/Gameplay"
@onready var option = $"../MenuList/Option"
@onready var fade_anim_player = $"../FadeAnimPlayer"
@onready var panel_fade = $"../Panel_Fade"
@onready var sfx_menu_click = $"../SFX_Menu_Click"

var current_menu
var change_target_menu

# 스크립트 시작
func _ready():
	set_game_condition.visible = false;
	gameplay.visible = false;
	option.visible = false;
	current_menu = main_menu
	current_menu.visible = true

# 메뉴 변경 함수
# 오디오 파일 재생 참고: https://www.youtube.com/watch?v=30fCw3qZCNw
func change_menu(page: Constants.MenuPage):
	# 메뉴의 visible설정을 바로 바꾸지 말고 페이드아웃/인 효과를 적용
	change_target_menu = page
	fade_anim_player.play("FadeOut")
	panel_fade.visible = true
	sfx_menu_click.play() # 사운드 재생

# 메뉴 변경시 플레이되는 페이드아웃 애니메이션 종료때 호출되는 함수
func _on_fade_out_complete():
	# 현재 메뉴를 숨기고 변경할 메뉴로 교체한다
	current_menu.visible = false;
	match change_target_menu:
		Constants.MenuPage.MainMenu:
			current_menu = main_menu
		Constants.MenuPage.SetGameCondition:
			current_menu = set_game_condition
		Constants.MenuPage.Gameplay:
			current_menu = gameplay
		Constants.MenuPage.Option:
			current_menu = option
	current_menu.visible = true
	# 교체후 페이드인 애니메이션 시작
	fade_anim_player.play("FadeIn")

# 페이드인 애니메이션 종료시 호출되는 함수
func _on_fade_in_complete():
	# 새 메뉴로 교체후 페이드인 종료시 페이드인/아웃 효과를 위한 패널이 보이는 상태면
	# 뒤에있는 컨트롤들에 클릭등 이벤트 처리가 안되므로 숨김처리한다
	panel_fade.visible = false

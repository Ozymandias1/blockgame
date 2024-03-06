extends CenterContainer

@onready var menu_controller = $"../../MenuController"
@onready var gameplay = $"../Gameplay"

# 보드 크기 옵션값 변경 시그널
func _on_option_board_size_item_selected(index):
	var board_size = index + 9
	gameplay.board_size = board_size # 보드사이즈(그리드컬럼개수) 설정
	
# Play 버튼 클릭 시그널
func _on_btn_play_pressed():
	menu_controller.change_menu(Constants.MenuPage.Gameplay)
	gameplay.gameplay_start()

# Back 버튼 클릭 시그널
func _on_btn_back_pressed():
	menu_controller.change_menu(Constants.MenuPage.MainMenu)

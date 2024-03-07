extends CenterContainer

#region 변수
@onready var menu_controller = $"../../MenuController"
#endregion

#region Start Game 버튼 클릭 시그널
func _on_btn_start_game_pressed():
	menu_controller.change_menu(Constants.MenuPage.SetGameCondition)
#endregion

#region Option 버튼 클릭 시그널
func _on_btn_option_pressed():
	menu_controller.change_menu(Constants.MenuPage.Option)
#endregion

#region Quit 버튼 클릭 시그널
func _on_btn_quit_pressed():
	get_tree().quit()
#endregion

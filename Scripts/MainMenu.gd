extends CenterContainer

@onready var menu_controller = $"../../MenuController"

# Start Game 버튼 클릭 시그널
func _on_btn_start_game_pressed():
	menu_controller.change_menu(Constants.MenuPage.SetGameCondition)

# Option 버튼 클릭 시그널
func _on_btn_option_pressed():
	menu_controller.change_menu(Constants.MenuPage.Option)

# Quit 버튼 클릭 시그널
func _on_btn_quit_pressed():
	get_tree().quit()

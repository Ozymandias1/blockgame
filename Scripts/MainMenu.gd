extends CenterContainer

#region Variables
@onready var menu_controller = $"../../MenuController"
#endregion

#region Signal: Start Game Button pressed signal
func _on_btn_start_game_pressed():
	menu_controller.change_menu(Constants.MenuPage.SetGameCondition)
#endregion

#region Signal: Option button pressed signal
func _on_btn_option_pressed():
	menu_controller.change_menu(Constants.MenuPage.Option)
#endregion

#region Signal: Quit button pressed signal
func _on_btn_quit_pressed():
	get_tree().quit()
#endregion

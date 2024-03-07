extends CenterContainer

#region Variables
@onready var menu_controller = $"../../MenuController"
@onready var gameplay = $"../Gameplay"
#endregion

#region Signal: called when board size select change
func _on_option_board_size_item_selected(index):
	var board_size = index + 9
	gameplay.board_size = board_size # set board size(grid column count)
#endregion

#region Signal: Play button pressed signal
func _on_btn_play_pressed():
	menu_controller.change_menu(Constants.MenuPage.Gameplay)
	gameplay.gameplay_start()
#endregion

#region Signal: Back Button pressed signal
func _on_btn_back_pressed():
	menu_controller.change_menu(Constants.MenuPage.MainMenu)
#endregion

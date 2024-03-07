extends Node

#region Variables
@onready var main_menu = $"../MenuList/MainMenu"
@onready var set_game_condition = $"../MenuList/SetGameCondition"
@onready var gameplay = $"../MenuList/Gameplay"
@onready var option = $"../MenuList/Option"
@onready var fade_anim_player = $"../FadeAnimPlayer"
@onready var panel_fade = $"../Panel_Fade"
@onready var sfx_menu_click = $"../SFX_Menu_Click"

var current_menu
var change_target_menu
#endregion

#region Function: script start
func _ready():
	# At the start, each menu is hidden and only the main menu scene is visible
	set_game_condition.visible = false;
	gameplay.visible = false;
	option.visible = false;
	current_menu = main_menu
	current_menu.visible = true
#endregion

#region Function: change menu
# reference for play audio: https://www.youtube.com/watch?v=30fCw3qZCNw
func change_menu(page: Constants.MenuPage):
	# Change the Visible setting of the menu by applying the fade-out/in effect instead of changing it immediately
	change_target_menu = page
	fade_anim_player.play("FadeOut")
	panel_fade.visible = true
	sfx_menu_click.play() # sfx play
#endregion

#region Function: called when fade-out animation finished
func _on_fade_out_complete():
	# hide current menu and show target menu
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
	# play fade in animation after change menu
	fade_anim_player.play("FadeIn")
#endregion

#region Function: called when fade-in animation finished
func _on_fade_in_complete():
	# If the panel for fade-in/out effect is visible when fade-in ends after
	# replacing with a new menu, the controls behind it cannot process events such as clicks,
	# so it is hidden (because the ignore setting of mouse_filter has not been set)
	panel_fade.visible = false
#endregion

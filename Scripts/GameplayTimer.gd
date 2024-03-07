extends Timer

#region Variables
@onready var label_time_value = $"../TopMenu/Gameplay_Menu_Bar/HBox_Time_Container/Label_Time_Value"
var game_elapsed_time: int = 0 # elapsed gameplay time
#endregion

#region Function: script start
func _ready():
	self.connect("timeout", _on_timer_process) # connect timer callback
#endregion

#region Function: Timer callback
# reference for time text formatting: https://forum.godotengine.org/t/how-to-convert-seconds-into-ddmm-ss-format/8174
func _on_timer_process():
	game_elapsed_time += 1 # I've been called for a second, so I've been accumulating for a second
	var seconds = game_elapsed_time % 60
	var minutes = (int)(game_elapsed_time / 60.0) % 60
	var timer_string = "%02d:%02d" % [minutes, seconds] # formatting text in mm:ss form
	label_time_value.text = timer_string
#endregion

#region Function: reset timer relaed variables
func reset_timer():
	game_elapsed_time = 0
	label_time_value.text = "00:00"
#endregion

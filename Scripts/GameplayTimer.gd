extends Timer

#region 변수
@onready var label_time_value = $"../TopMenu/Gameplay_Menu_Bar/HBox_Time_Container/Label_Time_Value"
var game_elapsed_time: int = 0 # 누적된 게임 진행시간
#endregion

#region 스크립트 시작 함수
func _ready():
	self.connect("timeout", _on_timer_process) # 타이머 콜백 연결
#endregion

#region 타이머 콜백 처리 함수
# https://forum.godotengine.org/t/how-to-convert-seconds-into-ddmm-ss-format/8174
func _on_timer_process():
	game_elapsed_time += 1 # 1초씩 호출되도록 했으므로 1초씩 누적
	var seconds = game_elapsed_time % 60
	var minutes = (int)(game_elapsed_time / 60.0) % 60
	var timer_string = "%02d:%02d" % [minutes, seconds] # 텍스트를 분:초 형식으로 표현
	label_time_value.text = timer_string
#endregion

#region 타이머 관련 요소 리셋 함수
func reset_timer():
	game_elapsed_time = 0
	label_time_value.text = "00:00"
#endregion

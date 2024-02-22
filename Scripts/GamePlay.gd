extends Control

@onready var board = $Board
@onready var pause_screen = $Pause
@onready var timer = $Timer
@onready var label_time_value = $TopMenu/Gameplay_Menu_Bar/HBox_Time_Container/Label_Time_Value
@onready var menu_controller = $"../../MenuController"

@onready var test = $Test

const BOARD_ITEM = preload("res://Prefabs/board_item.tscn")
var board_size: int:
	get:
		return board.columns
	set(value):
		board.columns = value
var game_elapsed_time: int = 0
var board_available_map: Dictionary

# 스크립트 시작
func _ready():
	pause_screen.get_node("Buttons/Btn_Resume").pressed.connect(_on_btn_resume_pressed)
	pause_screen.get_node("Buttons/Btn_ReturnToMainMenu").pressed.connect(_on_btn_returnToMainMenu) 
	timer.connect("timeout", _on_timer_process)
	board.columns = 9

# 보드판 초기화
func init_board():
	# 일시정지 화면 숨김 처리
	pause_screen.visible = false
	
	# 이전에 생성되어 있던 보드판 항목 제거
	for item in board.get_children():
		board.remove_child(item)
		item.queue_free()
		
	# 보드판 항목 생성후 추가
	board_available_map.clear()
	for y in range(board_size):
		for x in range(board_size):
			var item = BOARD_ITEM.instantiate()
			item.name = str("%s_%s" % [x,y])
			item.mouse_entered.connect(_on_block_mouse_entered.bind(item))
			board.add_child(item)
			board_available_map[Vector2i(x, y)] = true

# 게임플레이 시작
func gameplay_start():
	game_elapsed_time = 0
	timer.paused = false
	timer.start()
	
# 게임 진행시간 타이머 콜백 함수
# https://forum.godotengine.org/t/how-to-convert-seconds-into-ddmm-ss-format/8174
func _on_timer_process():
	game_elapsed_time += 1
	var seconds = game_elapsed_time % 60
	var minutes = (game_elapsed_time / 60) % 60
	var timer_string = "%02d:%02d" % [minutes, seconds]
	label_time_value.text = timer_string

# Pause 버튼 클릭 시그널
func _on_btn_pause_pressed():
	pause_screen.visible = true
	timer.paused = true

# Pause-Resume 버튼 클릭 시그널
func _on_btn_resume_pressed():
	pause_screen.visible = false
	timer.paused = false

# Pause-ReturnToMainMenu 버튼 클릭 시그널
func _on_btn_returnToMainMenu():
	menu_controller.change_menu(Constants.MenuPage.MainMenu)

func create_blocks():
	print("create_blocks() called.")

# 보드 배경 블럭 마우스 엔터 시그널
# https://www.reddit.com/r/godot/comments/yp3soy/comment/k9sx11d/
func _on_block_mouse_entered(item):
	print(item.name," ", item.size)
	test.global_position = item.global_position
	test.global_position.x += 16
	test.global_position.y += 16
	pass

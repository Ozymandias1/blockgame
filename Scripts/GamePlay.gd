extends Control

@onready var board = $Board
@onready var pause_screen = $Pause
@onready var timer = $Timer
@onready var label_time_value = $TopMenu/Gameplay_Menu_Bar/HBox_Time_Container/Label_Time_Value
@onready var menu_controller = $"../../MenuController"

@export var test_blocks: Array[Control]
var test_block_index = 0
var test_is_lock = false
var test_lock_pos = Vector2.ZERO

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

func _process(delta):
	if test_blocks.size() > 0:
		if test_is_lock:
			test_blocks[test_block_index].global_position = test_lock_pos
		else:
			test_blocks[test_block_index].global_position = get_global_mouse_position()
	pass

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
			item.set_meta("BoardIndex", Vector2i(x, y))
			item.mouse_entered.connect(_on_block_mouse_entered.bind(item))
			item.mouse_exited.connect(_on_block_mouse_exited)
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

# 배치용 블럭 생성
func create_placable_blocks():
	print("create_placable_blocks() called.")

# 블럭의 배치 가능 여부를 판별
func check_is_placeable(item_board_index: Vector2i):
	# 일단은 테스트 블럭으로
	if test_blocks.size() > 0:
		var test_block_indices = test_blocks[test_block_index].block_indices
		var matchCount = 0
		for p in test_block_indices:
			var check_point = Vector2i(item_board_index.x + p.x, item_board_index.y + p.y)
			if 0 <= check_point.x and 0 <= check_point.y and check_point.x < board.columns and check_point.y < board.columns:
				matchCount += 1
				
		return matchCount == test_block_indices.size()
	
	return true

# 보드 배경 블럭 마우스 엔터 시그널
# https://www.reddit.com/r/godot/comments/yp3soy/comment/k9sx11d/
func _on_block_mouse_entered(item):
	print('_on_block_mouse_entered:' + item.name," ", item.size)
	# item.set_meta("Board Index", Vector2i(x, y))
	if test_blocks.size() > 0:
		var item_board_index = item.get_meta("BoardIndex")
		if check_is_placeable(item_board_index):
			test_lock_pos = item.global_position
			test_lock_pos.x -= 30
			test_lock_pos.y -= 30
			test_is_lock = true
			test_blocks[test_block_index].set_opacity(1.0)
		else:
			test_is_lock = false
			test_blocks[test_block_index].set_opacity(0.5)
	pass

# 보드 배경 블럭 마우스 나감 시그널
func _on_block_mouse_exited():
	print('_on_block_mouse_exited')
	test_is_lock = false
	test_blocks[test_block_index].set_opacity(0.5)
	
func _unhandled_key_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_Q:
			test_block_index -= 1
			if test_block_index < 0:
				test_block_index = test_blocks.size() - 1
		if event.pressed and event.keycode == KEY_W:
			test_block_index += 1
			if test_block_index >= test_blocks.size():
				test_block_index = 0


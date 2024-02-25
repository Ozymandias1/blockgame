extends Control

@onready var board = $Board
@onready var pause_screen = $Pause
@onready var timer = $Timer
@onready var label_time_value = $TopMenu/Gameplay_Menu_Bar/HBox_Time_Container/Label_Time_Value
@onready var menu_controller = $"../../MenuController"
@onready var placable_block_area = $PlacableBlockArea

@export var placable_blocks: Array[PackedScene]
var current_block: Control;
var current_block_target_position: Vector2
var current_block_has_target: bool

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

# 업데이트
func _process(delta):
	if is_instance_valid(current_block):
		if current_block_has_target:
			current_block.global_position = current_block_target_position
		else:
			current_block.global_position = get_global_mouse_position()
			current_block.global_position.x -= 45
			current_block.global_position.y -= 45

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
	
	# 보드판 초기화 후 배치용 블럭 생성
	create_placable_blocks()

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
	# 이전에 남아있는 배치용 블럭 제거
	for item in placable_block_area.get_children():
		placable_block_area.remove_child(item)
		item.queue_free()
	# 새 배치용 블럭 생성
	for i in range(3):
		var new_block_source = placable_blocks.pick_random()
		var new_block = new_block_source.instantiate()
		new_block.gui_input.connect(_on_placable_block_gui_input.bind(new_block))
		placable_block_area.add_child(new_block)

# 블럭의 배치 가능 여부를 판별
func check_is_placeable(item_board_index: Vector2i):
	# 일단은 테스트 블럭으로
	var block_indices = current_block.block_indices
	var matchCount = 0
	for p in block_indices:
		var check_point = Vector2i(item_board_index.x + p.x, item_board_index.y + p.y)
		if 0 <= check_point.x and 0 <= check_point.y and check_point.x < board.columns and check_point.y < board.columns:
			matchCount += 1
			
	return matchCount == block_indices.size()

# 보드 배경 블럭 마우스 엔터 시그널
# 시그널에 매개변수 넘기기 참고: https://www.reddit.com/r/godot/comments/yp3soy/comment/k9sx11d/
func _on_block_mouse_entered(item):
	# 현재 배치할 블럭(클릭한것)이 유효하면
	# 마우스가 위치한 곳의 보드항목의 인덱스를 가져와
	# 배치블럭의 블럭인덱스값을 +-하여 배치가능한지 확인해보고
	# 배치가 가능하면 보드항목의 위치값으로 설정하고 아니면 마우스 좌표를 따라다니도록 한다
	if is_instance_valid(current_block):
		var item_board_index = item.get_meta("BoardIndex")
		if check_is_placeable(item_board_index):
			current_block_target_position = item.global_position
			current_block_target_position.x -= 29
			current_block_target_position.y -= 29
			current_block_has_target = true
			current_block.set_opacity(1.0)
			current_block.set_meta("BoardItemIndex", item_board_index)
		else:
			current_block_has_target = false
			current_block.set_opacity(0.5)
			current_block.set_meta("BoardItemIndex", null)

# 보드 배경 블럭 마우스 나감 시그널
func _on_block_mouse_exited():
	if is_instance_valid(current_block):
		current_block_has_target = false
		current_block.set_opacity(0.5)
		current_block.set_meta("BoardItemIndex", null)

# 보드판 크기변경 시그널
func _on_board_resized():
	# 배치용 블럭 공간 컨트롤 위치 조정
	placable_block_area.global_position.y = board.global_position.y + board.size.y + 60

# 하단 배치 대기용 블럭 입력 시그널
func _on_placable_block_gui_input(event: InputEvent, target):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			if not is_instance_valid(current_block):
				current_block = target
				current_block.mouse_filter = MOUSE_FILTER_IGNORE

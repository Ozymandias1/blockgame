extends Control

@onready var board = $Board
@onready var pause_screen = $Pause
@onready var game_over_screen = $GameOverScreen
@onready var timer = $Timer
@onready var label_score_value = $TopMenu/Gameplay_Menu_Bar/HBox_Score_Container/Label_Score_Value
@onready var label_time_value = $TopMenu/Gameplay_Menu_Bar/HBox_Time_Container/Label_Time_Value
@onready var menu_controller = $"../../MenuController"
@onready var placed_blocks = $PlacedBlocks
@onready var placable_block_area = $PlacableBlockArea

@onready var sfx_block_place_0 = $"../../SFX_Block_Place_0"
@onready var sfx_block_place_1 = $"../../SFX_Block_Place_1"
@onready var sfx_block_place_2 = $"../../SFX_Block_Place_2"
var sfx_block_place_list: Array[AudioStreamPlayer]

@onready var sfx_block_break_0 = $"../../SFX_Block_Break_0"
@onready var sfx_block_break_1 = $"../../SFX_Block_Break_1"
@onready var sfx_block_break_2 = $"../../SFX_Block_Break_2"
@onready var sfx_block_break_3 = $"../../SFX_Block_Break_3"
@onready var sfx_block_break_4 = $"../../SFX_Block_Break_4"
var sfx_block_break_list: Array[AudioStreamPlayer]

@export var placable_blocks: Array[PackedScene]
var current_block: Control;
var current_block_target_position: Vector2
var current_block_has_target: bool
var current_score: int = 0
var combo_ratio = 1;
var combo_reset_counter = 0

const COMBOTEXT = preload("res://Prefabs/combotext.tscn")
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
	game_over_screen.get_node("Buttons/Btn_ReturnToMainMenu").pressed.connect(_on_btn_returnToMainMenu)
	timer.connect("timeout", _on_timer_process)
	board.columns = 9
	
	sfx_block_place_list.append(sfx_block_place_0)
	sfx_block_place_list.append(sfx_block_place_1)
	sfx_block_place_list.append(sfx_block_place_2)
	
	sfx_block_break_list.append(sfx_block_break_0)
	sfx_block_break_list.append(sfx_block_break_1)
	sfx_block_break_list.append(sfx_block_break_2)
	sfx_block_break_list.append(sfx_block_break_3)
	sfx_block_break_list.append(sfx_block_break_4)

# 업데이트
func _process(delta):
	update_placable_block_location()

# 보드판 초기화
func init_board():
	# 일시정지, 게임오버, 진행시간 텍스트 처리
	pause_screen.visible = false
	game_over_screen.visible = false
	label_time_value.text = "00:00"
	current_score = 0
	combo_ratio = 1
	
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
			item.mouse_entered.connect(_on_board_item_mouse_entered.bind(item))
			item.mouse_exited.connect(_on_board_item_mouse_exited)
			item.gui_input.connect(_on_board_item_gui_input)
			board.add_child(item)
			board_available_map[Vector2i(x, y)] = true
	
	# 보드판 초기화 후 배치용 블럭 생성
	create_placable_blocks()
	# 이전에 배치되어있던 블럭 비우기
	claer_placed_blocks()

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
	# var test = [placable_blocks[placable_blocks.size()-1], placable_blocks[placable_blocks.size()-2]]
	for i in range(3):
		var new_block_source = placable_blocks.pick_random()
		var new_block = new_block_source.instantiate()
		new_block.gui_input.connect(_on_placable_block_gui_input.bind(new_block))
		placable_block_area.add_child(new_block)

# 블럭의 배치 가능 여부를 판별
func check_is_placeable(target_block, item_board_index: Vector2i):
	# 일단은 테스트 블럭으로
	var block_indices = target_block.block_indices
	var matchCount = 0
	for p in block_indices:
		var check_point = Vector2i(item_board_index.x + p.x, item_board_index.y + p.y)
		var available_map_check = false
		var board_region_check = false
		# 이미 배치된 블럭들과의 체크
		if board_available_map.has(check_point) and board_available_map[check_point]:
			available_map_check = true
		# 보드 판영역
		if 0 <= check_point.x and 0 <= check_point.y and check_point.x < board.columns and check_point.y < board.columns:
			board_region_check = true		
		# 매치 조건 확인
		if available_map_check and board_region_check:
			matchCount += 1
			
	return matchCount == block_indices.size()

# 보드 배경 블럭 마우스 엔터 시그널
# 시그널에 매개변수 넘기기 참고: https://www.reddit.com/r/godot/comments/yp3soy/comment/k9sx11d/
func _on_board_item_mouse_entered(item):
	# 현재 배치할 블럭(클릭한것)이 유효하면
	# 마우스가 위치한 곳의 보드항목의 인덱스를 가져와
	# 배치블럭의 블럭인덱스값을 +-하여 배치가능한지 확인해보고
	# 배치가 가능하면 보드항목의 위치값으로 설정하고 아니면 마우스 좌표를 따라다니도록 한다
	if is_instance_valid(current_block):
		var item_board_index = item.get_meta("BoardIndex")
		if check_is_placeable(current_block, item_board_index):
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
func _on_board_item_mouse_exited():
	if is_instance_valid(current_block):
		current_block_has_target = false
		current_block.set_opacity(0.5)
		current_block.set_meta("BoardItemIndex", null)

# 보드 배경 블럭 입력 처리 시그널
func _on_board_item_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			if is_instance_valid(current_block) and current_block_has_target:
				# 점수 업데이트
				current_score += current_block.score
				update_score_label_text()
				# 인덱스에 따른 배치 처리
				var current_block_board_item_index = current_block.get_meta("BoardItemIndex")
				mark_unavailable(current_block_board_item_index)
				break_current_block(current_block_board_item_index)
				# 배치시 사운드 효과 재생
				sfx_block_place_list.pick_random().play()
				# 보드판에 배치후에 배치대기중인 블럭이 없다면 새로 생성한다.
				if placable_block_area.get_child_count() == 0:
					create_placable_blocks()
				# 채워진 줄이 있는지 체크한다.
				if await check_complete_line():
					combo_reset_counter += 1 # 채워진 줄이 없는 경우가 3번이상인경우 콤보 배율 리셋 처리
					if combo_reset_counter == 3:
						# 리셋 체크를 하는 시점에서 이전 콤보 배율이 1이 아닌 경우가 리셋이 되는 경우이므로 텍스트를 띄워 알린다
						if combo_ratio != 1: 
							create_combo_reset_label(get_global_mouse_position())
						combo_ratio = 1
						combo_reset_counter = 0
				else:
					combo_reset_counter = 0
				# 게임오버를 체크한다.
				if check_gameover():
					show_gameover_screen()
					
				print('combo_ratio: %s, combo_reset_counter: %s' % [combo_ratio, combo_reset_counter])
# 보드판 크기변경 시그널
func _on_board_resized():
	# 배치용 블럭 공간 컨트롤 위치 조정
	placable_block_area.global_position.y = board.global_position.y + board.size.y + 60

# 하단 배치 대기용 블럭 입력(클릭) 시그널
func _on_placable_block_gui_input(event: InputEvent, target):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			if is_instance_valid(current_block): # 들고 있는 블럭이 있는 경우 먼저 취소하고 블럭 들기 작업 수행
				cancel_place_block()
			current_block = target
			current_block.mouse_filter = MOUSE_FILTER_IGNORE
			current_block_has_target = false
			# 배치용 블럭 컨테이너에서 게임플레이 루트 씬으로 부모 노드를 변경한다.
			current_block.get_parent().remove_child(current_block)
			placed_blocks.add_child(current_block)
			update_placable_block_location()

# 블럭 배치시 블럭 인덱스에 해당하는 부분에 사용 불가능 여부를 체크한다.
func mark_unavailable(targetIndex: Vector2i):
	if is_instance_valid(current_block):
		var block_indices = current_block.block_indices
		for p in block_indices:
			var mark_index = Vector2i(targetIndex.x + p.x, targetIndex.y + p.y)
			board_available_map[mark_index] = false

# 블럭을 분해하여 각 개별 블럭을 배치된 블럭 노드로 붙인다.
func break_current_block(current_block_board_item_index):
	current_block.apply_board_item_index(current_block_board_item_index)
	for child in current_block.get_children():
		var saved_child_global_position = child.global_position
		current_block.remove_child(child)
		placed_blocks.add_child(child)
		child.global_position = saved_child_global_position
	current_block.queue_free()
	current_block = null

# 배치중인(들고있는)블럭 위치 업데이트 함수
func update_placable_block_location():
	if is_instance_valid(current_block):
		if current_block_has_target:
			current_block.global_position = current_block_target_position
		else:
			current_block.global_position = get_global_mouse_position()
			current_block.global_position.x -= 45
			current_block.global_position.y -= 45

# 보드판에 배치되어 있던 블럭 모두 비우기
func claer_placed_blocks():
	for child in placed_blocks.get_children():
		placed_blocks.remove_child(child)
		child.queue_free()

# 채워진 라인 확인
func check_complete_line() -> bool:
	var break_delay: float = 0.0
	var break_delay_interval: float = 0.01
	var is_combo_reset = true
	# 가로줄 확인
	for y in board_size:
		var counter = 0
		
		for x in board_size:
			var index = Vector2i(x, y)
			if not board_available_map[index]:
				counter += 1
		
		# 채워진 가로줄이 있다면 x,y인덱스에 해당하는 이름의 노드를 찾아 제거하고
		# 인덱스에 해당하는 부분을 배치 가능상태로 전환한다.
		if counter == board_size:
			is_combo_reset = false
			for x in board_size:
				var target_node_name = "%s_%s" % [x, y]
				var delete_node = placed_blocks.get_node(target_node_name)
				if is_instance_valid(delete_node):
					# 마지막줄이면 콤보 라벨 생성
					if x == board_size-1:
						await get_tree().create_timer(break_delay).timeout
						create_combo_label(combo_ratio, delete_node.global_position)
					# 블럭 제거 및 점수 계산 처리
					delete_node.do_break_vfx(break_delay)
					sfx_block_break_list.pick_random().play()
					board_available_map[Vector2i(x, y)] = true
					break_delay += break_delay_interval
					current_score += 1 * combo_ratio
			combo_ratio += 1
	# 세로줄 확인
	for x in board_size:
		var counter = 0
		
		for y in board_size:
			var index = Vector2i(x, y)
			if not board_available_map[index]:
				counter += 1
		
		# 채워진 세로줄이 있다면 x,y인덱스에 해당하는 이름의 노드를 찾아 제거하고
		# 인덱스에 해당하는 부분을 배치 가능상태로 전환한다.
		if counter == board_size:
			is_combo_reset = false
			for y in board_size:
				var target_node_name = "%s_%s" % [x, y]
				var delete_node = placed_blocks.get_node(target_node_name)
				if is_instance_valid(delete_node):
					# 마지막줄이면 콤보 라벨 생성
					if y == board_size-1:
						await get_tree().create_timer(break_delay).timeout
						create_combo_label(combo_ratio, delete_node.global_position)
					delete_node.do_break_vfx(break_delay)
					sfx_block_break_list.pick_random().play()
					board_available_map[Vector2i(x, y)] = true
					break_delay += break_delay_interval
					current_score += 1 * combo_ratio
			combo_ratio += 1
	# 점수 텍스트 업데이트
	update_score_label_text()
	# 콤보 리셋 여부 반환
	return is_combo_reset

# 점수 텍스트 업데이트
func update_score_label_text():
	label_score_value.text = str(current_score)

# 게임 오버 조건 확인
func check_gameover():
	# 배치 대기중인 블럭들을 배치 가능한 곳이 있는지 확인
	for block in placable_block_area.get_children():
		for index_key in board_available_map.keys():
			if board_available_map[index_key]: # 배치가 가능한 인덱스라면
				# 블럭 인덱스로 체크하여 배치가능하다면 게임오버가 아니라고 판단
				if check_is_placeable(block, index_key):
					return false
	
	# 코드가 여기까지오면 배치가능한곳이 없으므로 게임오버로 판단한다
	return true

# 게임오버 스크린 보기
func show_gameover_screen():
	game_over_screen.get_node("Buttons/Label_FinalScore").text = tr("LOCALE_SCORE") + str(current_score)
	game_over_screen.visible = true
	timer.paused = true

# 콤보 텍스트 생성
func create_combo_label(ratio, target_pos):
	var label = COMBOTEXT.instantiate()
	label.global_position = target_pos
	label.call_deferred("set_combo_text_by_ratio", ratio)
	get_tree().get_root().add_child(label)

# 콤보 리셋 알림 텍스트 생성
func create_combo_reset_label(target_pos):
	var label = COMBOTEXT.instantiate()
	label.global_position = target_pos
	label.call_deferred("set_text", "COMBO RESET")
	get_tree().get_root().add_child(label)

# 블럭 배치 작업 취소
func cancel_place_block():
	if is_instance_valid(current_block):
		# 마우스를 따라다니는 배치 대기중인 블럭을 배치용 블럭 컨테이너로 다시 집어 넣는다.
		current_block.set_opacity(0.5)
		current_block.mouse_filter = Control.MOUSE_FILTER_STOP
		current_block.get_parent().remove_child(current_block)
		placable_block_area.add_child(current_block)
		current_block = null

func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_released() and event.keycode == KEY_ESCAPE:
			cancel_place_block()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_released():
			cancel_place_block()
		

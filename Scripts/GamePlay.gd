extends Control

#region Variables: scene related.
@onready var board = $Board
@onready var pause_screen = $Pause
@onready var game_over_screen = $GameOverScreen
@onready var timer = $GameplayTimer
@onready var label_score_value = $TopMenu/Gameplay_Menu_Bar/HBox_Score_Container/Label_Score_Value
@onready var menu_controller = $"../../MenuController"
@onready var placed_blocks = $PlacedBlocks
@onready var placable_block_area = $PlacableBlockArea
#endregion

#region Variables: Variables related to sound effects to play in block placement
@onready var sfx_block_place_0 = $"../../SFX_Block_Place_0"
@onready var sfx_block_place_1 = $"../../SFX_Block_Place_1"
@onready var sfx_block_place_2 = $"../../SFX_Block_Place_2"
var sfx_block_place_list: Array[AudioStreamPlayer]
#endregion

#region Variables: Variables related to sound effects to play in case of block destruction
@onready var sfx_block_break_0 = $"../../SFX_Block_Break_0"
@onready var sfx_block_break_1 = $"../../SFX_Block_Break_1"
@onready var sfx_block_break_2 = $"../../SFX_Block_Break_2"
@onready var sfx_block_break_3 = $"../../SFX_Block_Break_3"
@onready var sfx_block_break_4 = $"../../SFX_Block_Break_4"
var sfx_block_break_list: Array[AudioStreamPlayer]
#endregion

#region Variables: Variables related to block placement, score calculation, combo handling
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
var board_available_map: Dictionary
#endregion

#region Function: script start
func _ready():
	# Connect the button signal on the stop screen and the game over screen and set the default grid size to 9x9
	pause_screen.get_node("Buttons/Btn_Resume").pressed.connect(_on_btn_resume_pressed)
	pause_screen.get_node("Buttons/Btn_ReturnToMainMenu").pressed.connect(_on_btn_returnToMainMenu)
	game_over_screen.get_node("Buttons/Btn_ReturnToMainMenu").pressed.connect(_on_btn_returnToMainMenu)
	board.columns = 9
	
	# Add it to the array as it will be played randomly when playing sound effects
	sfx_block_place_list.append(sfx_block_place_0)
	sfx_block_place_list.append(sfx_block_place_1)
	sfx_block_place_list.append(sfx_block_place_2)
	
	sfx_block_break_list.append(sfx_block_break_0)
	sfx_block_break_list.append(sfx_block_break_1)
	sfx_block_break_list.append(sfx_block_break_2)
	sfx_block_break_list.append(sfx_block_break_3)
	sfx_block_break_list.append(sfx_block_break_4)
#endregion

#region Function: update
func _process(_delta):
	update_placable_block_location()
#endregion

#region Function: initialize board
func _init_board():
	# Pause, game over, progress text, score reset
	pause_screen.visible = false
	game_over_screen.visible = false
	timer.reset_timer()
	current_score = 0
	combo_ratio = 1
	
	# Remove background blocks from previously created
	for item in board.get_children():
		board.remove_child(item)
		item.queue_free()
		
	# Create a background block on the board
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
	
	# Create a block for placable after initializing the board
	create_placable_blocks()
	# remove previously placed blocks
	claer_placed_blocks()
#endregion

#region Function: gameplay start
func gameplay_start():
	_init_board()
	timer.reset_timer()
	timer.paused = false
	timer.start()
#endregion

#region Signal: pause button pressed
func _on_btn_pause_pressed():
	pause_screen.visible = true
	timer.paused = true
#endregion

#region Signal: resume button pressed in pause screen
func _on_btn_resume_pressed():
	pause_screen.visible = false
	timer.paused = false
#endregion

#region Signal: ReturnToMainMenu button pressed in pause screen
func _on_btn_returnToMainMenu():
	menu_controller.change_menu(Constants.MenuPage.MainMenu)
#endregion

#region Function: create placable blocks
func create_placable_blocks():
	# remove previously remaining blocks for create
	for item in placable_block_area.get_children():
		placable_block_area.remove_child(item)
		item.queue_free()
	# create new placable block
	for i in range(3):
		var new_block_source = placable_blocks.pick_random()
		var new_block = new_block_source.instantiate()
		new_block.gui_input.connect(_on_placable_block_gui_input.bind(new_block))
		placable_block_area.add_child(new_block)
#endregion

#region Function: determining whether blocks can be placed
func check_is_placeable(target_block, item_board_index: Vector2i):
	# Gets the reference index of the block to be placed
	var block_indices = target_block.block_indices
	var matchCount = 0
	# Identify whether or not the background block can be placed by +-ing 
	# the index of the background block from the reference index
	for p in block_indices: 
		var check_point = Vector2i(item_board_index.x + p.x, item_board_index.y + p.y)
		var available_map_check = false
		var board_region_check = false
		# Check with already placed blocks
		if board_available_map.has(check_point) and board_available_map[check_point]:
			available_map_check = true
		# Check if it is out of the board area
		if 0 <= check_point.x and 0 <= check_point.y and check_point.x < board.columns and check_point.y < board.columns:
			board_region_check = true		
		# Check the match condition and increase the matchCount if it is possible to place it
		if available_map_check and board_region_check:
			matchCount += 1
	
	# If the number of matchCounts and the number of reference indexes of the batch block are the same,
	# it is determined that the batch is possible
	return matchCount == block_indices.size()
#endregion

#region Signal: Board background block mouse enter signal
# reference for pass arguments in signal: https://www.reddit.com/r/godot/comments/yp3soy/comment/k9sx11d/
func _on_board_item_mouse_entered(item):
	# If the current block (clicked) is valid, take the index of the background
	# block where the mouse is located and check if the block index of the block
	# can be placed by +-
	# If possible, set it to the position value of the board item or
	# follow the mouse coordinates
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
#endregion

#region Signal: board background block mouse exit signal
func _on_board_item_mouse_exited():
	if is_instance_valid(current_block):
		current_block_has_target = false
		current_block.set_opacity(0.5)
		current_block.set_meta("BoardItemIndex", null)
#endregion

#region Signal: board background block gui input signal
func _on_board_item_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			if is_instance_valid(current_block) and current_block_has_target:
				# update placement score
				current_score += current_block.score
				update_score_label_text()
				# place by index
				var current_block_board_item_index = current_block.get_meta("BoardItemIndex")
				mark_unavailable(current_block_board_item_index)
				break_current_block(current_block_board_item_index)
				# play sfx when placement
				sfx_block_place_list.pick_random().play()
				# If there are no blocks waiting for placement after placement on the board, create a new one.
				if placable_block_area.get_child_count() == 0:
					create_placable_blocks()
				# Check if there are any lines complete.
				if await check_complete_line():
					combo_reset_counter += 1 # Resets combo ratio if no line is filled more than three times
					if combo_reset_counter == 3:
						# If the previous combo ratio is not 1 at the time of reset check, it will reset, so text will be displayed to notify
						if combo_ratio != 1: 
							create_combo_reset_label()
						combo_ratio = 1
						combo_reset_counter = 0
				else:
					combo_reset_counter = 0
				# check gameover
				if check_gameover():
					show_gameover_screen()
#endregion

#region Signal: board resize signal
func _on_board_resized():
	# adjust placable block area location
	placable_block_area.global_position.y = board.global_position.y + board.size.y + 60
#endregion

#region Signal: input signal for placable block
func _on_placable_block_gui_input(event: InputEvent, target):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			if is_instance_valid(current_block): # If you have a block you're holding, cancel it first and do the block lifting action
				cancel_place_block()
			# Set to the current block and set to ignore mouse input processing
			current_block = target
			current_block.mouse_filter = MOUSE_FILTER_IGNORE
			current_block_has_target = false
			# Change the parent node from the placable block container to the gameplay root scene.
			current_block.get_parent().remove_child(current_block)
			placed_blocks.add_child(current_block)
			update_placable_block_location()
#endregion

#region Function: A function that mark whether the part corresponding to the block index is unusable when placing a block.
func mark_unavailable(targetIndex: Vector2i):
	if is_instance_valid(current_block):
		var block_indices = current_block.block_indices
		for p in block_indices:
			var mark_index = Vector2i(targetIndex.x + p.x, targetIndex.y + p.y)
			board_available_map[mark_index] = false
#endregion

#region Function: A function that disassembles a block and attaches each individual block to a placed block node
func break_current_block(current_block_board_item_index):
	current_block.apply_board_item_index(current_block_board_item_index)
	for child in current_block.get_children():
		var saved_child_global_position = child.global_position
		current_block.remove_child(child)
		placed_blocks.add_child(child)
		child.global_position = saved_child_global_position
	current_block.queue_free()
	current_block = null
#endregion

#region Function: current block(holding) positoin update
func update_placable_block_location():
	if is_instance_valid(current_block):
		if current_block_has_target:
			current_block.global_position = current_block_target_position
		else:
			current_block.global_position = get_global_mouse_position()
			current_block.global_position.x -= 45
			current_block.global_position.y -= 45
#endregion

#region Function: A function that removes all blocks that previously placed
func claer_placed_blocks():
	for child in placed_blocks.get_children():
		placed_blocks.remove_child(child)
		child.queue_free()
#endregion

#region Function: Function to check if there is a complete line
func check_complete_line() -> bool:
	var break_delay: float = 0.0
	var break_delay_interval: float = 0.01
	var is_combo_reset = true
	# check horizontal line
	for y in board_size:
		var counter = 0
		
		for x in board_size:
			var index = Vector2i(x, y)
			if not board_available_map[index]:
				counter += 1
		
		# If there is a filled horizontal line, find and remove the node with the name
		# corresponding to the x,y index, and switch the portion corresponding to
		# the index to a placeable state.
		if counter == board_size:
			is_combo_reset = false
			for x in board_size:
				var target_node_name = "%s_%s" % [x, y]
				var delete_node = placed_blocks.get_node(target_node_name)
				if is_instance_valid(delete_node):
					# Create a combo label on the last
					if x == board_size-1:
						# If it breaks all at once, it's awkward, so I'll give you a delay and do a block break vfx
						await get_tree().create_timer(break_delay).timeout
						create_combo_label(combo_ratio)
					# remove block and score update
					delete_node.do_break_vfx(break_delay)
					sfx_block_break_list.pick_random().play()
					board_available_map[Vector2i(x, y)] = true
					break_delay += break_delay_interval
					current_score += 1 * combo_ratio
			combo_ratio += 1
	# check vertical line
	for x in board_size:
		var counter = 0
		
		for y in board_size:
			var index = Vector2i(x, y)
			if not board_available_map[index]:
				counter += 1
		
		# If there is a filled vertical line, find and remove the node with the name
		# corresponding to the x,y index, and switch the portion corresponding to
		# the index to a placeable state.
		if counter == board_size:
			is_combo_reset = false
			for y in board_size:
				var target_node_name = "%s_%s" % [x, y]
				var delete_node = placed_blocks.get_node(target_node_name)
				if is_instance_valid(delete_node):
					# Create a combo label on the last line
					if y == board_size-1:
						await get_tree().create_timer(break_delay).timeout
						create_combo_label(combo_ratio)
					delete_node.do_break_vfx(break_delay)
					sfx_block_break_list.pick_random().play()
					board_available_map[Vector2i(x, y)] = true
					break_delay += break_delay_interval
					current_score += 1 * combo_ratio
			combo_ratio += 1
	# update score text
	update_score_label_text()
	# return combo reset or not
	return is_combo_reset
#endregion

#region Function: update score text label
func update_score_label_text():
	label_score_value.text = str(current_score)
#endregion

#region Function: check gameover
func check_gameover() -> bool:
	# Verify that there is a place where blocks waiting to be placed can be placed
	for block in placable_block_area.get_children():
		for index_key in board_available_map.keys():
			if board_available_map[index_key]: # If it's an index that can be placed
				# Check by block index to determine that it is not a game over if it can be placed
				if check_is_placeable(block, index_key):
					return false
	
	# If the code gets this far, there is no placeable location, so I determine it as a game over
	return true
#endregion

#region Function: show gameover screen
func show_gameover_screen():
	# Show the final score within the game over scene
	game_over_screen.get_node("Buttons/Label_FinalScore").text = tr("LOCALE_FINALSCORE") + str(current_score)
	game_over_screen.visible = true
	timer.paused = true
#endregion

#region Function: create combo ratio text
func create_combo_label(ratio):
	var label = COMBOTEXT.instantiate()
	label.call_deferred("set_combo_text_by_ratio", ratio, get_board_center_position())
	get_tree().get_root().add_child(label)
#endregion

#region Function: create combo reset notify text
func create_combo_reset_label():
	var label = COMBOTEXT.instantiate()
	label.call_deferred("set_text", "COMBO RESET", get_board_center_position())
	get_tree().get_root().add_child(label)
#endregion

#region Function: cancel placement work
func cancel_place_block():
	if is_instance_valid(current_block):
		# Put the block waiting for the placement that follows the mouse back into the placeable block container.
		current_block.set_opacity(0.5)
		current_block.mouse_filter = Control.MOUSE_FILTER_STOP
		current_block.get_parent().remove_child(current_block)
		placable_block_area.add_child(current_block)
		current_block = null
#endregion

#region Signal: unhandled input signal
func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_released() and event.keycode == KEY_ESCAPE:
			cancel_place_block()
#endregion

#region Signal: handled input signal
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_released():
			cancel_place_block()
#endregion

#region Function: get board center position
func get_board_center_position() -> Vector2:
	var board_pos = board.global_position
	var board_control_size = board.size
	var result = Vector2(board_pos.x + (board_control_size.x * 0.5), board_pos.y + (board_control_size.y * 0.5))
	return result
#endregion

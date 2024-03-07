extends Control

#region Variables: block index, score related variables
var block_indices: Array[Vector2i]:
	get:
		var collected_indices: Array[Vector2i]
		for child in self.get_children():
			collected_indices.append(child.block_index)
		return collected_indices
var score: int:
	get:
		return block_indices.size() # the number of blocks becomes the default score for this block
#endregion

#region Variables: block texture related resources
const ELEMENT_BLUE_SQUARE = preload("res://Textures/element_blue_square.png")
const ELEMENT_GREEN_SQUARE = preload("res://Textures/element_green_square.png")
const ELEMENT_GREY_SQUARE = preload("res://Textures/element_grey_square.png")
const ELEMENT_PURPLE_SQUARE = preload("res://Textures/element_purple_square.png")
const ELEMENT_RED_SQUARE = preload("res://Textures/element_red_square.png")
const ELEMENT_YELLOW_SQUARE = preload("res://Textures/element_yellow_square.png")
#endregion

#region Function: script start
func _ready():
	set_block_textures()
	set_opacity(0.5)
#endregion

#region Function: child blocks transparency setting
func set_opacity(opacity: float = 1.0):
	for child in self.get_children():
		child.set_opacity(opacity)
#endregion

#region Function: applies board_item_index to child blocks.
# apply the index of the child blocks of the current block as the index of the board received as a factor (because it is called when the block is disassembled after placement)
func apply_board_item_index(board_item_index: Vector2i):
	for child in self.get_children():
		var target_index = board_item_index + child.block_index
		child.name = "%s_%s" % [target_index.x, target_index.y]
		child.block_index = target_index
#endregion

#region Function child blocks texture setting
func set_block_textures():
	var temp_tex_array = [
		ELEMENT_BLUE_SQUARE,
		ELEMENT_GREEN_SQUARE,
		ELEMENT_GREY_SQUARE,
		ELEMENT_PURPLE_SQUARE,
		ELEMENT_RED_SQUARE,
		ELEMENT_YELLOW_SQUARE
	]
	var selected_texture = temp_tex_array.pick_random()
	for child in self.get_children():
		child.set_texture(selected_texture) # use the set_texture() function of the component because the child's root is TextureRect
#endregion

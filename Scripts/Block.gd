extends Control

#region 인덱스, 점수 관련 변수
var block_indices: Array[Vector2i]:
	get:
		var collected_indices: Array[Vector2i]
		for child in self.get_children():
			collected_indices.append(child.block_index)
		return collected_indices
var score: int:
	get:
		return block_indices.size() # 블럭 개수가 이 블럭의 기본 점수가 됨
#endregion

#region 블럭 텍스쳐 관련 리소스
const ELEMENT_BLUE_SQUARE = preload("res://Textures/element_blue_square.png")
const ELEMENT_GREEN_SQUARE = preload("res://Textures/element_green_square.png")
const ELEMENT_GREY_SQUARE = preload("res://Textures/element_grey_square.png")
const ELEMENT_PURPLE_SQUARE = preload("res://Textures/element_purple_square.png")
const ELEMENT_RED_SQUARE = preload("res://Textures/element_red_square.png")
const ELEMENT_YELLOW_SQUARE = preload("res://Textures/element_yellow_square.png")
#endregion

#region 스크립트 시작
func _ready():
	set_block_textures()
	set_opacity(0.5)
#endregion

#region 자식 블럭들 투명도 설정 함수
func set_opacity(opacity: float = 1.0):
	for child in self.get_children():
		child.set_opacity(opacity)
#endregion

#region 자식 블럭들의 인덱스를 지정한 기준 인덱스값을 적용하는 함수
# 현재 블럭의 자식 블럭들의 인덱스를 인자로 받은 보드판의 인덱스 기준으로 적용한다(배치 후 블럭분해시 호출되므로)
func apply_board_item_index(board_item_index: Vector2i):
	for child in self.get_children():
		var target_index = board_item_index + child.block_index
		child.name = "%s_%s" % [target_index.x, target_index.y]
		child.block_index = target_index
#endregion

#region 자식 블럭들 텍스쳐를 설정하는 함수
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
		child.set_texture(selected_texture) # child의 루트가 TextureRect이므로 해당 컴포넌트의 set_texture() 함수 사용
#endregion

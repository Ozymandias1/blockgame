extends Control

var block_indices: Array[Vector2i]:
	get:
		var collected_indices: Array[Vector2i]
		for child in self.get_children():
			collected_indices.append(child.block_index)
		return collected_indices
		
func _ready():
	set_opacity(0.5)

# 블럭들 투명도 설정
func set_opacity(opacity: float = 1.0):
	for child in self.get_children():
		child.set_opacity(opacity)

# 현재 블럭내 자식 블럭 요소들의 인덱스를 보드판의 인덱스 기준으로 적용한다(배치후 블럭분해시 호출되므로)
func apply_board_item_index(board_item_index: Vector2i):
	for child in self.get_children():
		var target_index = board_item_index + child.block_index
		child.name = "%s_%s" % [target_index.x, target_index.y]
		child.block_index = target_index

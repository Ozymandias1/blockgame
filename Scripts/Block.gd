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
	

extends TextureRect

@export var block_index: Vector2i

# 블럭 텍스쳐 투명도 설정
func set_opacity(opacity: float = 1.0):
	self.modulate.a = opacity

# 블럭 부시는 효과처리
func do_break_vfx():
	print('do_break() called.')

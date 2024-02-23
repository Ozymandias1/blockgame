extends Control

@export var block_texture: Texture2D
@export var block_indices: Array[Vector2i]

func _ready():
	set_opacity(0.5)
	#var children = find_children("*", "TextureRect")
	#for child in children:
		##child.texture = block_texture
		#print(child.modulate)
		#child.modulate.a = 0.25
		#print(child.modulate)

# 블럭 투명도 설정
func set_opacity(opacity: float = 1.0):
	var children = find_children("*", "TextureRect")
	for child in children:
		child.modulate.a = opacity
	

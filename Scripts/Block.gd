extends Control

@export var block_texture: Texture2D
@export var block_indices: Array[Vector2i]

#func _ready():
	#var children = find_children("*", "Sprite2D")
	#for child in children:
		#child.texture = block_texture

extends TextureRect

@export var block_index: Vector2i
const BLOCK_BREAK_VFX = preload("res://Prefabs/Blocks/block_break_vfx.tscn")

# 블럭 텍스쳐 투명도 설정
func set_opacity(opacity: float = 1.0):
	self.modulate.a = opacity

# 블럭 부시는 효과처리
func do_break_vfx(wait_seconds = 0.1):
	await get_tree().create_timer(wait_seconds).timeout
	# 현재 블럭 자리에 vfx용 물리 블럭 4개 생성
	var temp_vfx_blocks = []
	for point in Constants.BlockVFXOffsets:
		var vfx = BLOCK_BREAK_VFX.instantiate()
		get_tree().get_root().add_child(vfx)
		vfx.global_position = self.global_position
		vfx.global_position += point
		temp_vfx_blocks.append(vfx)

	# 각 블럭 요소에 속도 적용
	var v_min = 50
	var v_max = 300
	var velocity = Vector2.ZERO
	# 좌측 하단,상단
	velocity.x = randf_range(-v_max, -v_min)
	velocity.y = randf_range(-v_max, -v_min)
	temp_vfx_blocks[Constants.BlockVFXLocation.LEFT_BOTTOM].linear_velocity = velocity
	velocity.x = randf_range(-v_max, -v_min)
	velocity.y = randf_range(-v_max, -v_min)
	temp_vfx_blocks[Constants.BlockVFXLocation.LEFT_TOP].linear_velocity = velocity
	# 우측 상단,하단
	velocity.x = randf_range(v_min, v_max)
	velocity.y = randf_range(-v_max, -v_min)
	temp_vfx_blocks[Constants.BlockVFXLocation.RIGHT_TOP].linear_velocity = velocity
	velocity.x = randf_range(v_min, v_max)
	velocity.y = randf_range(-v_max, -v_min)
	temp_vfx_blocks[Constants.BlockVFXLocation.RIGHT_BOTTOM].linear_velocity = velocity
	# 정지상태 해제
	for vfx in temp_vfx_blocks:
		vfx.freeze = false
	
	# 현재 블럭 제거
	self.get_parent().remove_child(self)
	self.queue_free()

	

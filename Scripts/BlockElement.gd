extends TextureRect

#region 변수
@export var block_index: Vector2i # 배치 가능 여부 판별을 위한 현재 블럭 요소의 인덱스
const BLOCK_BREAK_VFX = preload("res://Prefabs/Blocks/block_break_vfx.tscn") # 블럭 파괴 효과를 위한 블럭 vfx 씬
#endregion

#region 투명도 설정 함수
func set_opacity(opacity: float = 1.0):
	self.modulate.a = opacity
#endregion

#region 블럭 부시는 효과처리 함수
# 딜레이 적용 참고: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-for-signals-or-coroutines
func do_break_vfx(wait_seconds = 0.1):
	# 지정된 시간만큼 대기후 수행
	await get_tree().create_timer(wait_seconds).timeout
	# 현재 블럭 자리에 vfx용 물리 블럭 4개 생성한다
	var temp_vfx_blocks = []
	for point in Constants.BlockVFXOffsets:
		var vfx = BLOCK_BREAK_VFX.instantiate()
		get_tree().get_root().add_child(vfx)
		vfx.get_node("CollisionShape2D/Sprite2D").texture = self.texture
		vfx.global_position = self.global_position
		vfx.global_position += point
		temp_vfx_blocks.append(vfx)

	# 각 블럭 요소에 속도 적용
	# 완전 랜덤으로 하면 이상한 경우가 많이 보이므로 좌측 상하단은 좌측위방향으로,
	# 우측 상하단은 우측위방향으로 속도를 설정한다
	var v_min = 50
	var v_max = 300
	var velocity = Vector2.ZERO
	# 좌측 하단,상단 속도 적용
	velocity.x = randf_range(-v_max, -v_min)
	velocity.y = randf_range(-v_max, -v_min)
	temp_vfx_blocks[Constants.BlockVFXLocation.LEFT_BOTTOM].linear_velocity = velocity
	velocity.x = randf_range(-v_max, -v_min)
	velocity.y = randf_range(-v_max, -v_min)
	temp_vfx_blocks[Constants.BlockVFXLocation.LEFT_TOP].linear_velocity = velocity
	# 우측 상단,하단 속도 적용
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
#endregion
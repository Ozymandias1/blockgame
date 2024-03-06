extends Control

#region 변수
@onready var animation_player = $AnimationPlayer
@onready var label_combo = $LabelCombo
#endregion

#region 스크립트 시작
func _ready():
	# 노드가 씬에 생성됨과 동시에 애니메이션을 재생한다
	animation_player.play("combo_label_anim")
#endregion

#region 애니메이션 종료시 호출되는 함수
func _on_combo_label_anim_finished():
	# 애니메이션 종료시 텍스트를 제거한다
	self.get_parent().remove_child(self)
	self.queue_free()
#endregion

#region 콤보배율 텍스트 설정 함수
func set_combo_text_by_ratio(ratio, target_pos):
	label_combo.text = "x%s" % ratio
	# BoxContainer는 하위 자식객체들에 따라 자동으로 크기가 조정되는 것으로 보이나
	# 크기 업데이트가 변경직후가 아니라 변경이후 렌더링한 후에 이루어 지는 것으로 추정됨
	# 강제로 크기 업데이트하는것을 못찾아서 일단 링크에 따라 꼼수? 비슷한 방법으로
	# 컨트롤 사이즈를 커스텀최소사이즈로 설정하면 변경된 크기를 얻을 수 있는것으로 보이므로 일단 이 코드로 진행
	# https://forum.godotengine.org/t/how-to-force-container-to-recalculate-own-rect-size/26236
	# https://www.reddit.com/r/godot/comments/qksh50/how_to_force_container_to_recalculate/
	self.size = self.custom_minimum_size
	
	# 목표 위치에서 가로 너비의 반만큼 왼쪽으로 이동
	target_pos.x -= self.size.x * 0.5
	self.global_position = target_pos
#endregion

#region 콤보배율 표현이 아닌 일반 텍스트를 위해 사용할때의 함수
func set_text(text, target_pos):
	label_combo.text = text
	self.size = self.custom_minimum_size
	
	# 목표 위치에서 가로 너비의 반만큼 왼쪽으로 이동
	target_pos.x -= self.size.x * 0.5
	self.global_position = target_pos
#endregion

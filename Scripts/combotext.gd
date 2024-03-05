extends Control

@onready var animation_player = $AnimationPlayer
@onready var label_combo = $LabelCombo

func _ready():
	animation_player.play("combo_label_anim")

func _on_combo_label_anim_finished():
	self.get_parent().remove_child(self)
	self.queue_free()
	
func set_combo_text_by_ratio(ratio, target_pos):
	label_combo.text = "x%s" % ratio
	# BoxContainer는 하위 자식객체들에 따라 자동으로 크기가 조정되는 것으로 보이나
	# 크기 업데이트가 변경직후가 아니라 변경이후 렌더링한 후에 이루어 지는 것으로 추정됨
	# 강제로 크기 업데이트하는것을 못찾아서 일단 링크에 따라 꼼수? 비슷한 방법으로
	# 컨트롤 사이즈를 커스텀최소사이즈로 설정하면 변경된 크기를 얻을 수 있는것으로 보이므로 일단 이 코드로 진행
	self.size = self.custom_minimum_size
	
	# 목표 위치에서 가로 너비의 반만큼 왼쪽으로 이동
	target_pos.x -= self.size.x * 0.5
	self.global_position = target_pos
	
func set_text(text, target_pos):
	label_combo.text = text
	self.size = self.custom_minimum_size
	
	# 목표 위치에서 가로 너비의 반만큼 왼쪽으로 이동
	target_pos.x -= self.size.x * 0.5
	self.global_position = target_pos

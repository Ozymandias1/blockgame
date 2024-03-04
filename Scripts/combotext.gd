extends Control

@onready var animation_player = $AnimationPlayer
@onready var label_combo = $LabelCombo

func _ready():
	animation_player.play("combo_label_anim")

func _on_combo_label_anim_finished():
	self.get_parent().remove_child(self)
	self.queue_free()
	
func set_combo_text_by_ratio(ratio):
	label_combo.text = "x%s" % ratio
	_adjust_position()
	
func set_text(text):
	label_combo.text = text
	_adjust_position()
	
# 컨트롤의 우측 일부분이 화면 밖으로 나가는 경우가 생기므로 위치 조정을 한다
func _adjust_position():	
	# BoxContainer는 하위 자식객체들에 따라 자동으로 크기가 조정되는 것으로 보이나
	# 크기 업데이트가 변경직후가 아니라 변경이후 렌더링한 후에 이루어 지는 것으로 추정됨
	# 강제로 크기 업데이트하는것을 못찾아서 일단 링크에 따라 꼼수? 비슷한 방법으로
	# 컨트롤 사이즈를 커스텀최소사이즈로 설정하면 변경된 크기를 얻을 수 있는것으로 보이므로 일단 이 코드로 진행
	# https://www.reddit.com/r/godot/comments/qksh50/how_to_force_container_to_recalculate/
	self.size = self.custom_minimum_size
	
	# 위치+가로 너비가 화면 크기를 벗어나는지 확인하여 벗어난만큼 왼쪽으로 위치조정
	var viewport_size = get_viewport().size
	var control_right = self.global_position.x + self.size.x;
	if viewport_size.x < control_right:
		var offset = control_right - viewport_size.x
		self.global_position.x -= offset

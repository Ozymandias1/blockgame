extends RigidBody2D

# VisibleOnScreenNotifier2D의 화면 밖으로 나갔을때의 시그널 처리
func _on_visible_on_screen_notifier_2d_screen_exited():
	# 현재 노드를 부모로부터 제거하고 메모리 해제
	self.get_parent().remove_child(self)
	self.queue_free()

extends RigidBody2D

#region Signal: called when object out of screen on VisibleOnScreenNotifier2D node
func _on_visible_on_screen_notifier_2d_screen_exited():
	# remove the current node from its parent and release memory
	self.get_parent().remove_child(self)
	self.queue_free()
#endregion

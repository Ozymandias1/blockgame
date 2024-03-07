extends Control

#region Variables
@onready var animation_player = $AnimationPlayer
@onready var label_combo = $LabelCombo
#endregion

#region Function: script start
func _ready():
	# play animation when node created.
	animation_player.play("combo_label_anim")
#endregion

#region Function: called when label animation finished.
func _on_combo_label_anim_finished():
	# when finish animation, remove label
	self.get_parent().remove_child(self)
	self.queue_free()
#endregion

#region Function: combo ratio text setting function
func set_combo_text_by_ratio(ratio, target_pos):
	label_combo.text = "x%s" % ratio
	# BoxContainer appears to be automatically resized by child objects,
	# but it is estimated that the size update takes place after rendering, not immediately after, the change
	# i can't find any forced size update, so once I set the control size to custom minimum according to the link,
	# it seems that I can get the changed size, so I'll proceed with this code for now
	# https://forum.godotengine.org/t/how-to-force-container-to-recalculate-own-rect-size/26236
	# https://www.reddit.com/r/godot/comments/qksh50/how_to_force_container_to_recalculate/
	self.size = self.custom_minimum_size
	
	# move left by half the width of the width from the target position
	target_pos.x -= self.size.x * 0.5
	self.global_position = target_pos
#endregion

#region Function: set text not combo ratio
func set_text(text, target_pos):
	label_combo.text = text
	self.size = self.custom_minimum_size
	
	# move left by half the width of the width from the target position
	target_pos.x -= self.size.x * 0.5
	self.global_position = target_pos
#endregion

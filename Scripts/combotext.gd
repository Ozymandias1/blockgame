extends Control

@onready var animation_player = $LabelCombo/AnimationPlayer
@onready var label_combo = $LabelCombo

func _ready():
	animation_player.play("combo_label_anim")

func _on_combo_label_anim_finished():
	self.get_parent().remove_child(self)
	self.queue_free()
	
func set_combo_text(ratio):
	label_combo.text = "x%s" % ratio

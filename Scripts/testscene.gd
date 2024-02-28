extends Node

@onready var left_top = $LeftTop
@onready var right_top = $RightTop
@onready var left_bottom = $LeftBottom
@onready var right_bottom = $RightBottom

func _ready():
	left_top.get_node("VisibleOnScreenNotifier2D").screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited.bind(left_top))
	right_top.get_node("VisibleOnScreenNotifier2D").screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited.bind(right_top))
	left_bottom.get_node("VisibleOnScreenNotifier2D").screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited.bind(left_bottom))
	right_bottom.get_node("VisibleOnScreenNotifier2D").screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited.bind(right_bottom))

func _on_btn_break_pressed():
	var velocity = Vector2(0, 0)
	velocity.x = randf_range(-300.0, -50)
	velocity.y = randf_range(-300.0, -50)
	left_bottom.linear_velocity = velocity
	
	velocity.x = randf_range(-300.0, -50)
	velocity.y = randf_range(-300.0, -50)
	left_top.linear_velocity = velocity
	
	velocity.x = randf_range(50.0, 300)
	velocity.y = randf_range(-300.0, -50)
	right_top.linear_velocity = velocity
	
	velocity.x = randf_range(50.0, 300)
	velocity.y = randf_range(-300.0, -50)
	right_bottom.linear_velocity = velocity
	
	left_top.freeze = false
	right_top.freeze = false
	left_bottom.freeze = false
	right_bottom.freeze = false


func _on_btn_reset_pressed():
	get_tree().reload_current_scene()

func _on_visible_on_screen_notifier_2d_screen_exited(target):
	target.get_parent().remove_child(target)
	target.queue_free()

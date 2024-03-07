extends Node

@onready var block_element = $BlockElement

const BLOCK_BREAK_VFX = preload("res://Prefabs/Blocks/block_break_vfx.tscn")
var vfx_block_list = []

func _ready():
	var points = [
		Vector2(7.5, 22.5),
		Vector2(7.5, 7.5),
		Vector2(22.5, 7.5),
		Vector2(22.5, 22.5),
	]
	for p in points:
		var vfx = BLOCK_BREAK_VFX.instantiate()
		get_tree().current_scene.add_child(vfx)
		vfx.global_position = block_element.global_position
		vfx.global_position += p
		vfx_block_list.append(vfx)

func _on_btn_break_pressed():
	var velocity_min = 50
	var velocity_max = 300
	var velocity = Vector2.ZERO
	
	# Left Bottom, Top
	velocity.x = randf_range(-velocity_max, -velocity_min)
	velocity.y = randf_range(-velocity_max, -velocity_min)
	vfx_block_list[0].linear_velocity = velocity
	velocity.x = randf_range(-velocity_max, -velocity_min)
	velocity.y = randf_range(-velocity_max, -velocity_min)
	vfx_block_list[1].linear_velocity = velocity
	
	# Right Top
	velocity.x = randf_range(velocity_min, velocity_max)
	velocity.y = randf_range(-velocity_max, -velocity_min)
	vfx_block_list[2].linear_velocity = velocity
	velocity.x = randf_range(velocity_min, velocity_max)
	velocity.y = randf_range(-velocity_max, -velocity_min)
	vfx_block_list[3].linear_velocity = velocity
	
	# Unfreeze
	for vfx in vfx_block_list:
		vfx.freeze = false
	
func _on_btn_reset_pressed():
	get_tree().reload_current_scene()

func _on_visible_on_screen_notifier_2d_screen_exited(target):
	target.get_parent().remove_child(target)
	target.queue_free()

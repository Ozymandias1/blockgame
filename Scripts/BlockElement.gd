extends TextureRect

#region Variables
@export var block_index: Vector2i # index of current block elements for determining placable
const BLOCK_BREAK_VFX = preload("res://Prefabs/Blocks/block_break_vfx.tscn") # block vfx scene for block destruction effect
#endregion

#region Function: set opacity
func set_opacity(opacity: float = 1.0):
	self.modulate.a = opacity
#endregion

#region Function: block destruction
# reference for apply time delay: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-for-signals-or-coroutines
func do_break_vfx(wait_seconds = 0.1):
	# perform a destruction after a specified amount of time
	await get_tree().create_timer(wait_seconds).timeout
	# create 4 physical applied blocks for vfx in the current block location
	var temp_vfx_blocks = []
	for point in Constants.BlockVFXOffsets:
		var vfx = BLOCK_BREAK_VFX.instantiate()
		get_tree().get_root().add_child(vfx)
		vfx.get_node("CollisionShape2D/Sprite2D").texture = self.texture
		vfx.global_position = self.global_position
		vfx.global_position += point
		temp_vfx_blocks.append(vfx)

	# set speed to each block element
	# if it is completely random, in my case there are many strange cases.
	# so, based on the center position, apply force to the left side blocks to left-up direction,
	# and the right side blocks to right-up direction.
	var v_min = 50
	var v_max = 300
	var velocity = Vector2.ZERO
	# Left Bottom, Top
	velocity.x = randf_range(-v_max, -v_min)
	velocity.y = randf_range(-v_max, -v_min)
	temp_vfx_blocks[Constants.BlockVFXLocation.LEFT_BOTTOM].linear_velocity = velocity
	velocity.x = randf_range(-v_max, -v_min)
	velocity.y = randf_range(-v_max, -v_min)
	temp_vfx_blocks[Constants.BlockVFXLocation.LEFT_TOP].linear_velocity = velocity
	# Right Top, Bottom
	velocity.x = randf_range(v_min, v_max)
	velocity.y = randf_range(-v_max, -v_min)
	temp_vfx_blocks[Constants.BlockVFXLocation.RIGHT_TOP].linear_velocity = velocity
	velocity.x = randf_range(v_min, v_max)
	velocity.y = randf_range(-v_max, -v_min)
	temp_vfx_blocks[Constants.BlockVFXLocation.RIGHT_BOTTOM].linear_velocity = velocity
	# unfreeze physics state
	for vfx in temp_vfx_blocks:
		vfx.freeze = false
	
	# remove current block
	self.get_parent().remove_child(self)
	self.queue_free()
#endregion

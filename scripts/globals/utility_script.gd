extends Node




# Reusable helpers for “mirrored input when flipped” with hysteresis.
# Put these in a utility script or inside your player script.
var _facing_left: bool = false

func update_facing_hysteresis(px_x: float, center_x: float, margin_px: float, current_facing_left: bool) -> bool:
	# Returns the new facing state (left = true) using hysteresis.
	if current_facing_left:
		# Switch back to right only if clearly to the right
		if px_x > center_x + margin_px:
			return false
		return true
	else:
		# Switch to left only if clearly to the left
		if px_x < center_x - margin_px:
			return true
		return false

func mirror_x_about_center(px_x: float, width: float) -> float:
	# Mirrors x inside [0..width] space.
	return width - px_x


func compute_mirrored_target(
	target_node: Node2D,
	input_world_pos: Vector2,
	shader_sprite: Sprite2D,
	subviewport: SubViewport,
	distance: float = 5000.0,     # max distance of TARGET from its parent
	offset: Vector2 = Vector2(0, 0),
	margin_px: float = 24.0,
	facing_left_override: Variant = null
) -> Vector2:
	if target_node == null:
		return Vector2.ZERO
	if shader_sprite == null or subviewport == null:
		return target_node.global_position

	var tex := shader_sprite.texture
	if tex == null:
		return target_node.global_position

	var tex_size := tex.get_size()

	# World -> texture pixel space
	var m_local := shader_sprite.to_local(input_world_pos)
	var px := m_local + tex_size * 0.5

	# Facing
	var facing_left: bool
	if facing_left_override != null:
		facing_left = bool(facing_left_override)
	else:
		var center_x := tex_size.x * 0.5
		_facing_left = update_facing_hysteresis(px.x, center_x, margin_px, _facing_left)
		facing_left = _facing_left

	shader_sprite.flip_h = facing_left

	# Mirror X when flipped
	if facing_left:
		px.x = mirror_x_about_center(px.x, tex_size.x)

	# Texture pixels -> subviewport pixels
	var sv_size := subviewport.size
	var sv_px := Vector2(
		px.x * (sv_size.x / tex_size.x),
		px.y * (sv_size.y / tex_size.y)
	)

	# Subviewport pixels -> world
	var desired_world := subviewport.get_canvas_transform().affine_inverse() * sv_px

	# Clamp TARGET position relative to its PARENT
	var parent := target_node.get_parent() as Node2D
	var final_world := desired_world
	if parent != null and distance > 0.0:
		var center := parent.global_position
		var v := desired_world - center
		var len := v.length()
		if len > distance:
			final_world = center + (v / len) * distance

	target_node.global_position = final_world + offset
	return final_world


# Follows a target point with distance clamp + offset.
# Same viewport (no SubViewport) and no mirroring / shader sprite.
# Optionally drives target_node.global_position for convenience.

func compute_follow_target(
	target_node: Node2D,
	input_world_pos: Vector2,
	distance: float = 5000.0,     # max distance of TARGET from its parent
	offset: Vector2 = Vector2(0, 0)
) -> Vector2:
	if target_node == null:
		return Vector2.ZERO

	# Desired world position is simply the input in the same viewport/world
	var desired_world := input_world_pos

	# Clamp TARGET position relative to its PARENT
	var parent := target_node.get_parent() as Node2D
	var final_world := desired_world
	if parent != null and distance > 0.0:
		var center := parent.global_position
		var v := desired_world - center
		var len := v.length()
		if len > distance:
			final_world = center + (v / len) * distance

	target_node.global_position = final_world + offset
	return final_world

#func compute_mirrored_target(
	#target_node: Node2D,          # e.g. head_look_at
	#input_world_pos: Vector2,     # e.g. mouse_world (or any world position)
	#shader_sprite: Sprite2D,      # the Sprite2D displaying the viewport texture
	#subviewport: SubViewport,     # the SubViewport being rendered
	##Add this variable here "Distance" determines how far from parent should it be following
	#margin_px: float = 24.0,
	#facing_left_override: Variant = null # pass true/false to force, or leave null to auto
#) -> Vector2:
	#var tex := shader_sprite.texture
	#if tex == null:
		#return target_node.global_position
#
	#var tex_size := tex.get_size()
#
	## Convert input world position to texture pixel space
	#var m_local := shader_sprite.to_local(input_world_pos)
	#var px := m_local + tex_size * 0.5
#
	## Decide facing (either forced or hysteresis-driven)
	#var facing_left: bool
	#if facing_left_override != null:
		#facing_left = bool(facing_left_override)
	#else:
		#var center_x := tex_size.x * 0.5
		#_facing_left = update_facing_hysteresis(px.x, center_x, margin_px, _facing_left)
		#facing_left = _facing_left
#
	## Apply visual flip
	#shader_sprite.flip_h = facing_left
#
	## Mirror input X if flipped so logic matches the mirrored render
	#if facing_left:
		#px.x = mirror_x_about_center(px.x, tex_size.x)
#
	## Map texture pixels -> subviewport pixels
	#var sv_size := subviewport.size
	#var sv_px := Vector2(
		#px.x * (sv_size.x / tex_size.x),
		#px.y * (sv_size.y / tex_size.y)
	#)
#
	## Subviewport pixel -> world
	#var sv_world := subviewport.get_canvas_transform().affine_inverse() * sv_px
#
	## Apply and return
	#target_node.global_position = sv_world
	#return sv_world

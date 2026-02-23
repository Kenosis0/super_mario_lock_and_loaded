extends Camera2D

@export var player: Node2D

@export var follow_speed: float = 10.0      # higher = snappier
@export var max_vertical_offset: float = 250.0  # clamp above/below player (world units)
@export var max_horizontal_offset: float = 250.0
@export var deadzone_y: float = 0.0         # ignore tiny mouse jitter (0..3 recommended)
@export var deadzone_x: float = 0.0

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	var vp := get_viewport()

	# Mouse in world space
	var mouse_world: Vector2 = vp.get_canvas_transform().affine_inverse() * vp.get_mouse_position()

	# Clamp mouse Y around player so it won't pull too far
	var desired_y = clamp(
		mouse_world.y,
		player.global_position.y - max_vertical_offset,
		player.global_position.y + max_vertical_offset
	)
	
	var desired_x = clamp(
		mouse_world.x,
		player.global_position.x - max_horizontal_offset,
		player.global_position.x + max_horizontal_offset,
	)

	# Optional: deadzone to prevent micro-jitter when mouse is still
	if deadzone_y > 0.0 and abs(desired_y - global_position.y) < deadzone_y:
		desired_y = global_position.y
	
	if deadzone_x > 0.0 and abs(desired_x - global_position.x) < deadzone_x:
		deadzone_x = global_position.x
	
	# Smooth Y toward desired_y, lock X to player
	var t := 1.0 - exp(-follow_speed * delta)
	global_position.x = lerp(global_position.x, desired_x, t)
	global_position.y = lerp(global_position.y, desired_y, t)
	
#extends Camera2D
#
#@export var player: Player
#@export var follow_speed: float = 10.0
#
#@export_range(0.0, 1.0) var mouse_influence := 0.35
#@export var mouse_offset: Vector2
#@export var screen_padding := Vector2(180, 120)
#
#@export var face_influence := 0.25  # how far to look ahead when not using mouse
#
#var _last_facing := Vector2.RIGHT
#
#func _process(delta: float) -> void:
	#return
	#if not is_instance_valid(player):
		#return
#
	#var vp := get_viewport()
	#var view_size := vp.get_visible_rect().size
#
	## Safe-box clamp limits
	#var half_view := view_size * 0.5
	#var max_offset_screen := Vector2(
		#max(0.0, half_view.x - screen_padding.x),
		#max(0.0, half_view.y - screen_padding.y)
	#)
	#var max_offset_world := Vector2(
		#max_offset_screen.x / zoom.x,
		#max_offset_screen.y / zoom.y
	#)
#
	#var offset := Vector2.ZERO
	#var rmb_down := Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	#
	##var mouse_world := vp.get_canvas_transform().affine_inverse() * vp.get_mouse_position()
	##mouse_world += mouse_offset  # <-- apply exported offset in WORLD units
#
	##offset = (mouse_world - player.global_position) * mouse_influence
	#var facing := _last_facing
#
	#if player is Player:
		#var fd: Vector2 = (player as Player).face_dir
		#if fd.length_squared() > 0.0001:
			#facing = fd.normalized()
			#_last_facing = facing
#
	## Look-ahead distance derived from clamp range
	#offset = facing * (max_offset_world.length() * face_influence)
	#offset -= Vector2(0, 300)
	## Clamp so player stays inside the safe box
	#offset.x = clamp(offset.x, -max_offset_world.x, max_offset_world.x)
	#offset.y = clamp(offset.y, -max_offset_world.y, max_offset_world.y)
#
	#var desired_pos := player.global_position + offset 
#
	## Smooth follow
	#global_position = global_position.lerp(desired_pos, 1.0 - exp(-follow_speed * delta))
	#
	#return
	#if player.using_sling:
		#print("using sling")
		## Mouse follow while slinging
		#
	#else:
		## Facing-based look-ahead (no velocity)
		#pass
#
	#

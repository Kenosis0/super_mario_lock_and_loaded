extends Node2D
@onready var mouse: Polygon2D = $Mouse
@onready var target: Polygon2D = $Target


func _process(delta: float) -> void:
	mouse.global_position = get_global_mouse_position()

	#follow_target(target, get_global_mouse_position())
	#if target == null:
		#return
#
	#var mouse_g := get_global_mouse_position()
#
	## Compute direction in the BONE PARENT'S local space (important)
	#var parent := target.get_parent() as Node2D
	#if parent == null:
		#return
#
	#var mouse_p := parent.to_local(mouse_g)
	#var bone_p  := parent.to_local(target.global_position)
	#var dir := mouse_p - bone_p
	#if dir.length_squared() == 0.0:
		#return
#
	#var raw := dir.angle()
	#target.rotation = fold_to_front_half(raw)


func follow_target(host: Node2D,  target_pos: Vector2) -> void:
	if host == null:
		return

	# Compute direction in the BONE PARENT'S local space (important)
	var parent := host.get_parent() as Node2D
	if parent == null:
		return

	var target_p := parent.to_local(target_pos)
	var bone_p  := parent.to_local(host.global_position)
	var dir := target_p - bone_p
	if dir.length_squared() == 0.0:
		return

	var raw := dir.angle()
	host.rotation = fold_to_front_half(raw)


func fold_to_front_half(a: float) -> float:
	a = wrapf(a, -PI, PI)
	if a > PI * 0.5:
		a = PI - a
	elif a < -PI * 0.5:
		a = -PI - a
	return a

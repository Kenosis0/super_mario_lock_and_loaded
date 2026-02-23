extends Node2D

@export var slingshot: Node2D
@export var max_distance: float = 120.0
@export var sprite_faces_up: bool = false

func _process(_delta: float) -> void:
	if slingshot == null:
		return

	var center: Vector2 = global_position
	var mouse: Vector2 = get_global_mouse_position()

	var offset := mouse - center
	var distance := offset.length()

	# ---- LIMIT DISTANCE ----
	if distance > max_distance:
		offset = offset.normalized() * max_distance

	slingshot.global_position = center + offset
	# ------------------------

	# ---- ROTATION (no upside-down) ----
	if offset.length() > 0.001:
		var angle := offset.angle()

		var behind = abs(angle) > PI * 0.5

		# Flip instead of rotating 180°
		slingshot.scale.x = -1.0 if behind else 1.0

		var clamped_angle = clamp(angle, -PI * 0.5, PI * 0.5)

		if sprite_faces_up:
			clamped_angle += deg_to_rad(90)

		slingshot.rotation = clamped_angle

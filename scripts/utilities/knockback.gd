# Knockback.gd
extends RefCounted
class_name Knockback

var force: float
var decay: float

var vel: Vector2 = Vector2.ZERO

func _init(_force: float = 400.0, _decay: float = 1200.0) -> void:
	force = _force
	decay = _decay

func apply_from(source_global_pos: Vector2, target_global_pos: Vector2, amount: float = -1.0) -> void:
	# Push target away from source
	var dir := (target_global_pos - source_global_pos).normalized()
	var f := force if amount < 0.0 else amount
	vel = dir * f

func apply_dir(direction: Vector2, amount: float = -1.0) -> void:
	# direction should point where you want to push
	var dir := direction.normalized()
	var f := force if amount < 0.0 else amount
	vel = dir * f

func update(delta: float) -> void:
	# Decay toward zero each physics tick
	vel = vel.move_toward(Vector2.ZERO, decay * delta)

func add_to(base_velocity: Vector2) -> Vector2:
	return base_velocity + vel

func clear() -> void:
	vel = Vector2.ZERO

func is_active(epsilon: float = 0.5) -> bool:
	return vel.length() > epsilon

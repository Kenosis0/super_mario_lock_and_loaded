extends CharacterBody2D
class_name Rock

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Node2D = $Sprite
@onready var col: CollisionShape2D = $CollisionShape2D

@export var rotate_lerp_speed := 18.0 # higher = snappier
@export var lifetime: float = 2.0

# Gravity for prediction + actual motion (must match preview)
@export var gravity: float = 2200.0

# Bounce tuning (deterministic)
@export_range(0.0, 1.0, 0.01) var restitution: float = 0.2   # 0 = no bounce, 1 = perfect
@export_range(0.0, 1.0, 0.01) var friction: float = 0.15     # tangential energy loss per bounce

@export var max_bounces: int = 6
@export var min_speed_to_stop: float = 35.0

var bounces_done: int = 0



var used_by: Node2D

func _ready() -> void:
	anim.speed_scale = randf_range(1.0, 2.0)
	#anim.play("rotating")
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func launch(v0: Vector2, _owner: Node2D) -> void:
	velocity = v0
	used_by = _owner

func _physics_process(delta: float) -> void:
	# gravity
	velocity.y += gravity * delta

	# rotate to velocity direction (only if moving)
	if velocity.length_squared() > 1.0:
		var target_angle := velocity.angle()
		sprite.rotation = lerp_angle(sprite.rotation, target_angle, 1.0 - exp(-rotate_lerp_speed * delta))

	# move & collide
	var col := move_and_collide(velocity * delta)
	if col:
		_on_hit(col)

#func _physics_process(delta: float) -> void:
	## gravity
	#velocity.y += gravity * delta
#
	## move & collide using CharacterBody2D
	#var col := move_and_collide(velocity * delta)
	#if col:
		#_on_hit(col)

func _on_hit(col: KinematicCollision2D) -> void:
	col.set_deferred("disabled", true)

	bounces_done += 1
	if bounces_done > max_bounces:
		queue_free()
		return

	var n := col.get_normal().normalized()

	# reflect velocity
	var v_reflect := velocity - 2.0 * velocity.dot(n) * n

	# split into normal/tangent
	var vN := n * v_reflect.dot(n)
	var vT := v_reflect - vN

	# apply restitution + friction
	vN *= restitution
	vT *= clamp(1.0 - friction, 0.0, 1.0)

	velocity = vN + vT

	# stop if basically dead
	if velocity.length() < min_speed_to_stop:
		queue_free()
		return

	# push off surface slightly to avoid immediate re-collision
	global_position += n * 0.5
	
	if used_by:
		var goomba = col.get_collider()
		if goomba is Goomba:
			goomba.apply_knockback(global_position, used_by.power)

extends CharacterBody2D
class_name Rock

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Node2D = $Sprite

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
	# If you want enemies to "take hit" but rock continues bouncing:
	# var collider = col.get_collider()
	# if collider and collider.is_in_group("enemies"):
	#     collider.take_damage(...)
	#     # do NOT return; still bounce

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
			#print("goomba hit!")
#extends RigidBody2D
#class_name Rock
#
#@onready var anim: AnimationPlayer = $AnimationPlayer
#
#@export var lifetime: float = 2.0
#@export var max_speed: float = 1800.0
#
#func _ready() -> void:
	#anim.speed_scale = randf_range(1.0, 2.0)
	#anim.play("rotating")
	#get_tree().create_timer(lifetime).timeout.connect(queue_free)
#
#func launch(v0: Vector2) -> void:
	## Match preview: no hidden changes besides clamp
	#if v0.length() > max_speed:
		#v0 = v0.normalized() * max_speed
#
	#linear_velocity = v0
	#angular_velocity = randf_range(-10.0, 10.0)

#extends CharacterBody2D
#class_name Rock
#
#@onready var anim: AnimationPlayer = $AnimationPlayer
#
#@export var lifetime: float = 2.0
#@export var gravity: float = 2200.0          # tune for your game feel
#@export var max_launch_speed: float = 1400.0 # safety clamp
#
#func _ready() -> void:
	#anim.speed_scale = randf_range(1.0, 2.0)
	#anim.play("rotating")
	#get_tree().create_timer(lifetime).timeout.connect(queue_free)
#
#func _physics_process(delta: float) -> void:
	#velocity.y += gravity * delta
	#var col := move_and_collide(velocity * delta)
	#if col:
		#queue_free()
#
## --- Launch styles ---
#
## 1) Fixed time to target (most controllable for gameplay)
#func launch_to(target: Vector2, time_sec: float) -> void:
	#time_sec = max(time_sec, 0.05)
#
	#var p0 := global_position
	#var p1 := target
	#var v := (p1 - p0) / time_sec
#
	## Compensate gravity so we still arrive at target in time_sec
	## p(t)=p0 + v*t + 0.5*g*t^2  => v = (p1-p0)/t - 0.5*g*t
	#v.y -= 0.5 * gravity * time_sec
#
	#if v.length() > max_launch_speed:
		#v = v.normalized() * max_launch_speed
#
	#velocity = v
#
## 2) Fixed angle (classic artillery)
#func launch_with_angle(target: Vector2, angle_deg: float) -> void:
	#var p0 := global_position
	#var p1 := target
	#var dx := p1.x - p0.x
	#var dy := p1.y - p0.y
#
	#var ang := deg_to_rad(clamp(angle_deg, 5.0, 85.0))
	#var cos_a := cos(ang)
	#var tan_a := tan(ang)
#
	## Same-side only: if target is behind, flip the angle direction
	#if dx < 0.0:
		#dx = -dx
		#p1.x = p0.x - dx
		#cos_a = cos(ang) # unchanged, we’ll apply sign later
#
	## v^2 = g*dx^2 / (2*cos^2(a)*(dx*tan(a) - dy))
	#var denom := 2.0 * cos_a * cos_a * (dx * tan_a - dy)
	#if denom <= 0.0:
		## Target too high/close for this angle; fallback to time-based
		#launch_to(target, 0.45)
		#return
#
	#var v2 := gravity * dx * dx / denom
	#var v := sqrt(v2)
#
	#var sign_x = sign(target.x - p0.x)
	#velocity = Vector2(v * cos_a * sign_x, -v * sin(ang))
#extends Area2D
#class_name Rock
#@onready var anim: AnimationPlayer = $AnimationPlayer
#@export var speed: float = 900.0
#@export var lifetime: float = 2.0
#
#var dir: Vector2 = Vector2.RIGHT
#
#func _ready() -> void:
	#anim.speed_scale = randf_range(1.0, 2.0)
	#anim.play("rotating")
	#dir = dir.normalized()
	## Auto-despawn
	#get_tree().create_timer(lifetime).timeout.connect(queue_free)
	#body_entered.connect(_on_body_entered)
	#area_entered.connect(_on_area_entered)
#
#func _physics_process(delta: float) -> void:
	#global_position += dir * speed * delta
#
#func _on_body_entered(_body: Node) -> void:
	#queue_free()
#
#func _on_area_entered(_area: Area2D) -> void:
	#queue_free()

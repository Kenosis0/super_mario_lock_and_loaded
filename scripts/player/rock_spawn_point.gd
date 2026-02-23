extends Marker2D
const ROCK = preload("uid://lkxpxt25v0y")

@onready var traj_line: Line2D = $TrajectoryLine
#
@export var base_speed: float = 900.0 
@export var max_speed: float = 1800.0 
#@export var upward_boost: float = 0.35  
#
@export var player: Player
@export var traj_steps: int = 40
#@export var traj_max_bounces: int = 2
#
## These should match (roughly) your Rock's PhysicsMaterial
#@export var preview_restitution: float = 0.35  # bounce
#@export var preview_friction: float = 0.20     # tangential energy loss per bounce (0..1)
#
#@export var rock_material: PhysicsMaterial

var rock_gravity
var rock_restitution
var rock_friction
var rock_collision_mask


func _ready() -> void:
	var temp := ROCK.instantiate()
	if temp is Rock:
		rock_gravity = temp.gravity
		rock_restitution = temp.restitution
		rock_friction = temp.friction
		rock_collision_mask = temp.collision_mask
	temp.queue_free()


func _physics_process(delta: float) -> void:
	var mouse_world = player.get_mouse_world()
	var v0 := player.compute_v0(self.global_position, mouse_world, player.power)
	if player.using_sling:
		draw_trajectory_with_bounce(self.global_position, v0)
	else:
		if traj_line.points.size():
			traj_line.clear_points()


func draw_trajectory_with_bounce(origin: Vector2, v0: Vector2) -> void:
	if traj_line == null:
		return

	traj_line.clear_points()

	var dt := 1.0 / float(Engine.physics_ticks_per_second)
	var space := get_world_2d().direct_space_state

	var p := origin
	var v := v0
	var bounces := 0
	var max_bounces := 2 # preview only (set as you want)

	traj_line.add_point(to_local(p))

	for _i in traj_steps:
		# same gravity integration as Rock
		v += Vector2(0, rock_gravity) * dt
		var next_p := p + v * dt

		var q := PhysicsRayQueryParameters2D.create(p, next_p)
		
		q.collide_with_bodies = true
		q.collide_with_areas = false
		q.collision_mask = rock_collision_mask
		q.exclude = [player.get_rid()] # only if player is CollisionObject2D
		var hit := space.intersect_ray(q)

		if hit.size() == 0:
			traj_line.add_point(to_local(next_p))
			p = next_p
			continue

		var hp: Vector2 = hit.position
		var n: Vector2 = hit.normal.normalized()
		traj_line.add_point(to_local(hp))

		if bounces >= max_bounces:
			return
		bounces += 1

		# SAME bounce math as Rock._on_hit()
		var v_reflect := v - 2.0 * v.dot(n) * n
		var vN := n * v_reflect.dot(n)
		var vT := v_reflect - vN

		vN *= rock_restitution
		vT *= clamp(1.0 - rock_friction, 0.0, 1.0)

		v = vN + vT
		p = hp + n * 0.5




#func _process(_delta: float) -> void:
	#var mouse_world = player.get_mouse_world()
	#var power := player.power # replace with your real value
#
	#var v0 := compute_v0(self.global_position, mouse_world, power)
	##draw_trajectory(self.global_position, v0, 1.0)
	#draw_trajectory_with_bounce(self.global_position, v0, 1.0, rock_material)
#
#
#func _get_material_from_collider(collider: Object) -> PhysicsMaterial:
	## Works for most PhysicsBody2D (StaticBody2D/RigidBody2D/CharacterBody2D)
	#if collider != null and collider.has_method("get"):
		#var mat = collider.get("physics_material_override")
		#if mat is PhysicsMaterial:
			#return mat
	#return null
#
#func _combined_bounce(rock_mat: PhysicsMaterial, other_mat: PhysicsMaterial) -> float:
	#var a_b := rock_mat.bounce if rock_mat else 0.0
	#var b_b := other_mat.bounce if other_mat else 0.0
#
	#var a_abs := rock_mat.absorbent if rock_mat else false
	#var b_abs := other_mat.absorbent if other_mat else false
#
	## Use the doc rule: "subtract ... instead of adding it" :contentReference[oaicite:2]{index=2}
	## We treat rock as "A" colliding with "B" (surface).
	#var res := (b_b - a_b) if a_abs else (b_b + a_b)
	## If the surface is absorbent too, it subtracts its bounce as well.
	#res = (a_b - b_b) if b_abs else res
#
	#return clamp(res, 0.0, 1.0)
#
#func _combined_friction(rock_mat: PhysicsMaterial, other_mat: PhysicsMaterial) -> float:
	#var a_f := rock_mat.friction if rock_mat else 1.0
	#var b_f := other_mat.friction if other_mat else 1.0
#
	#var a_r := rock_mat.rough if rock_mat else false
	#var b_r := other_mat.rough if other_mat else false
#
	## Godot doc behavior :contentReference[oaicite:3]{index=3}
	#if a_r and b_r:
		#return max(a_f, b_f)
	#if a_r:
		#return a_f
	#if b_r:
		#return b_f
	#return min(a_f, b_f)
#
#func draw_trajectory_with_bounce(origin: Vector2, v0: Vector2, rock_gravity_scale: float, rock_mat: PhysicsMaterial) -> void:
	#if traj_line == null:
		#return
#
	#traj_line.clear_points()
#
	#var dt := 1.0 / float(Engine.physics_ticks_per_second)
	#var g := float(ProjectSettings.get_setting("physics/2d/default_gravity")) * rock_gravity_scale
	#var space := get_world_2d().direct_space_state
#
	#var p := origin
	#var v := v0
	#var bounces := 0
	#var max_bounces := traj_max_bounces
#
	#traj_line.add_point(to_local(p))
#
	#for _i in traj_steps:
		## integrate
		#v += Vector2(0, g) * dt
		#var next_p := p + v * dt
#
		#var q := PhysicsRayQueryParameters2D.create(p, next_p)
		#q.collide_with_bodies = true
		#q.collide_with_areas = true
		#var hit := space.intersect_ray(q)
#
		#if hit.size() == 0:
			#traj_line.add_point(to_local(next_p))
			#p = next_p
			#continue
#
		#var hp: Vector2 = hit.position
		#var n: Vector2 = hit.normal.normalized()
		#traj_line.add_point(to_local(hp))
#
		#if bounces >= max_bounces:
			#return
		#bounces += 1
#
		#var other_mat := _get_material_from_collider(hit.collider)
		#var e := _combined_bounce(rock_mat, other_mat)
		#var mu := _combined_friction(rock_mat, other_mat)
#
		## reflect
		#var v_reflect := v - 2.0 * v.dot(n) * n
#
		## split
		#var vN := n * v_reflect.dot(n)
		#var vT := v_reflect - vN
#
		## apply restitution + friction-ish tangential loss
		#vN *= e
		#vT *= clamp(1.0 - mu, 0.0, 1.0)
#
		#v = vN + vT
#
		## push off surface a bit to avoid instant re-hit
		#p = hp + n * 0.5
#
#
#func compute_v0(origin: Vector2, target: Vector2, power: float) -> Vector2:
	#var dir := (target - origin).normalized()
	#var speed = clamp(base_speed * power, 0.0, max_speed)
#
	#var v = dir * speed
#
	#return v


#func draw_trajectory_with_bounce(origin: Vector2, v0: Vector2, rock_gravity_scale: float = 1.0) -> void:
	#if traj_line == null:
		#return
#
	#traj_line.clear_points()
#
	#var dt := 1.0 / float(Engine.physics_ticks_per_second)
	#var g := float(ProjectSettings.get_setting("physics/2d/default_gravity")) * rock_gravity_scale
#
	#var space := get_world_2d().direct_space_state
#
	#var p := origin
	#var v := v0
	#var bounces := 0
#
	#traj_line.add_point(to_local(p))
#
	#for _i in traj_steps:
		## integrate (semi-implicit Euler, matches typical physics stepping better)
		#v += Vector2(0, g) * dt
		#var next_p := p + v * dt
#
		## raycast the segment so we don't "skip" through thin walls
		#var q := PhysicsRayQueryParameters2D.create(p, next_p, 1)
		#q.collide_with_bodies = true
		#q.collide_with_areas = true
		#var hit := space.intersect_ray(q)
#
		#if hit.size() == 0:
			#traj_line.add_point(to_local(next_p))
			#p = next_p
			#continue
#
		## stop the line at impact point
		#var hp: Vector2 = hit.position
		#var n: Vector2 = hit.normal.normalized()
		#traj_line.add_point(to_local(hp))
#
		## if we don't want more bounces, end here
		#if bounces >= traj_max_bounces:
			#return
		#bounces += 1
#
		## Reflect velocity and apply restitution (bounce)
		## v' = v - 2*(v·n)*n
		#var vn := v.dot(n)
		#var v_reflect := v - 2.0 * vn * n
#
		## Restitution: only affects the normal component realistically
		## Split into normal + tangential, scale them separately.
		#var vN := n * v_reflect.dot(n)
		#var vT := v_reflect - vN
#
		#vN *= preview_restitution                 # bounce loss
		#vT *= clamp(1.0 - preview_friction, 0.0, 1.0)  # tangential loss (fake friction)
#
		#v = vN + vT
#
		## push slightly off the surface to avoid immediate re-hit on next ray
		#p = hp + n * 0.5
#
#
##func draw_trajectory(origin: Vector2, v0: Vector2, rock_gravity_scale: float = 1.0) -> void:
	##if traj_line == null:
		##return
##
	##traj_line.clear_points()
##
	##var dt := 1.0 / float(Engine.physics_ticks_per_second)
##
	### Use the SAME gravity system as RigidBody2D
	##var world_g := float(ProjectSettings.get_setting("physics/2d/default_gravity")) * rock_gravity_scale
##
	##var space := get_world_2d().direct_space_state
	##var p := origin
	##var v := v0
##
	##traj_line.add_point(to_local(p))
##
	##for i in traj_steps:
		##v += Vector2(0, world_g) * dt
		##var next_p := p + v * dt
##
		##var q := PhysicsRayQueryParameters2D.create(p, next_p)
		##q.collide_with_bodies = true
		##q.collide_with_areas = true
##
		##var hit := space.intersect_ray(q)
		##if hit.size() > 0:
			##traj_line.add_point(to_local(hit.position))
			##return
##
		##traj_line.add_point(to_local(next_p))
		##p = next_p



#@onready var traj_line: Line2D = $TrajectoryLine
#
#@export var traj_steps := 40
#@export var traj_dt := 0.04
#
## Same gravity value you use on the projectile
##@export var gravity := 2200.0
#
#func _process(_delta: float) -> void:
	#var player: Player = (get_parent() as Player)
	#var mouse_world := player.get_mouse_world()
	#var origin := self.global_position
	#var power := player.power # replace with your weapon power
	#
#
	#var v0 := compute_v0(origin, mouse_world, power)
	#draw_trajectory(origin, v0)
#
#func compute_v0(origin: Vector2, target: Vector2, power: float) -> Vector2:
	## Option 1: time-based aim (consistent arc). Tune base_time.
	#var base_time := 0.45
	#var t = max(base_time / max(power, 0.05), 0.05)
	#var gravity = float(ProjectSettings.get_setting("physics/2d/default_gravity"))
	#
	#var v = (target - origin) / t
	#v.y -= 0.5 * gravity * t
	#return v
#
#func draw_trajectory(origin: Vector2, v0: Vector2) -> void:
	#traj_line.clear_points()
	#var space := get_world_2d().direct_space_state
	#var gravity = float(ProjectSettings.get_setting("physics/2d/default_gravity"))
	#
	#var p := origin
	#var v := v0
#
	#traj_line.add_point(to_local(p))
#
	#for i in traj_steps:
		#var next_v := v + Vector2(0, gravity) * traj_dt
		#var next_p := p + next_v * traj_dt
#
		## Stop line at first hit
		#var q := PhysicsRayQueryParameters2D.create(p, next_p)
		#q.collide_with_areas = true
		#q.collide_with_bodies = true
		#var hit := space.intersect_ray(q)
#
		#if hit.size() > 0:
			#traj_line.add_point(to_local(hit.position))
			#return
#
		#traj_line.add_point(to_local(next_p))
		#p = next_p
		#v = next_v

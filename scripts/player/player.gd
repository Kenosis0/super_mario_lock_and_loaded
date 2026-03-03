extends CharacterBody2D
class_name Player

const ROCK = preload("uid://lkxpxt25v0y")

@onready var util = UtilityScript as UtilityScript
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var shader_sprite: Sprite2D = $Render/ShaderSprite
@onready var sv: SubViewport = %SubViewport
@onready var ready_sling_cooldown: Timer = $ReadySlingCooldown
@onready var limb_control_component: LimbControlComponent = $LimbControlComponent

@export var walk_speed := 520.0 
@export var sprint_speed  := 2000.0
@export var walk_accel := 1200.0
@export var sprint_accel := 3000.0 
@export var walk_decel := 12000.0
@export var sprint_decel := 14000.0

@export var jump_velocity := 2400
@export var gravity_weight := 6200

@export var walk_turn_accel := 16000.0
@export var sprint_turn_accel := 20000.0

@export var air_walk_accel := 5000.0
@export var air_sprint_accel := 4500.0
@export var air_walk_decel := 3500.0
@export var air_sprint_decel := 3000.0
@export var air_walk_turn_accel := 7000.0
@export var air_sprint_turn_accel := 8000.0

var input_x := 0.0
var face_dir: Vector2 = Vector2.RIGHT
var jump_alpha := 0.0 # 0..1..0
var can_jump: bool = false
var using_sling: bool = false
#var is_falling: bool = false


@export var limb_timer: float = 1.0
@export var handr_distance: float = 500
@export var handl_distance: float = 500
@export_range(0.0, 1.0, 0.01) var handr_distance_ratio: float = 1.0
@export_range(0.0, 1.0, 0.01) var handl_distance_ratio: float = 1.0
@export_node_path("Marker2D") var _hand_r
@export_node_path("Node2D") var head_look_at
@export_node_path("Marker2D") var _hand_l

@export_node_path("Marker2D") var rock_spawn_point
var has_weapon: bool = false
var firing: bool
var limb_count: float = limb_timer
@export var power: float = 1.0


func _ready() -> void:
	print("player viewport: ", get_viewport().get_instance_id())
	var rock = get_node(rock_spawn_point)
	print("muzzle viewport: ", rock.get_viewport().get_instance_id())


func _unhandled_input(event: InputEvent) -> void:
	if using_sling:
		if Input.is_action_pressed("fire") and firing == false:
			using_sling = true
			limb_count = limb_timer
			var tween_slingshot = get_tree().create_tween()
			tween_slingshot.tween_property(self, "handr_distance_ratio", 0.1, .5)
			
			firing = true
			
			await tween_slingshot.finished
			
			fire(power, self)
			handr_distance_ratio = 1.0
			print("fired")
			firing = false
	else:
		if Input.is_action_just_pressed("fire"):
			using_sling = true
			limb_count = limb_timer
			limb_control_component.enable_look_at_cursor(false)
			print("now using sling")
			return


func _process(delta: float) -> void:
	var mouse = get_global_mouse_position()
	
	if is_moving_forward():
		anim_tree.set("parameters/WalkScale/scale", 1.6)
		anim_tree.set("parameters/RunScale/scale", 1.23)
	
	var rock_spawn = get_node(rock_spawn_point)
	util.compute_follow_target(rock_spawn, mouse, 180, Vector2(0, -20))
	
	if using_sling == false:
		return
	
	if !is_moving_forward():
		anim_tree.set("parameters/WalkScale/scale", -1.6)
		anim_tree.set("parameters/RunScale/scale", -1.23)
	
	var node_head_look_at = get_node(head_look_at)
	util.compute_mirrored_target(node_head_look_at,  mouse,  shader_sprite,  sv)
	
	var new_handl_distance = handl_distance * handl_distance_ratio
	var hand_l = get_node(_hand_l)
	util.compute_mirrored_target(hand_l, mouse, shader_sprite, sv, new_handl_distance, Vector2(0, 70))
	
	var new_handr_distance = handr_distance * handr_distance_ratio
	var hand_r = get_node(_hand_r)
	util.compute_mirrored_target(hand_r, mouse, shader_sprite, sv, new_handr_distance, Vector2(0, -50))
	
	
	if limb_count > 0:
		limb_count -= delta
	elif limb_count <= 0 and using_sling:
		limb_control_component.enable_look_at_cursor(true)
		using_sling = false
	
	


func _physics_process(delta: float) -> void:
	input_x = Input.get_axis("left", "right")
	
	if input_x != 0.0:
		face_dir = Vector2(input_x, 0.0)
	
	var want_move = abs(input_x) > 0.001
	var want_sprint = Input.is_action_pressed("sprint") and want_move
	var grounded := is_on_floor()

	# flip
	if want_move:
		shader_sprite.flip_h = input_x < 0

	# gravity
	if not grounded:
		velocity.y += gravity_weight * delta
		velocity.y = min(velocity.y, gravity_weight)
		var takeoff = max(1.0, abs(jump_velocity))
		var t = abs(velocity.y) / takeoff   # 0..inf
		t = t / (1.0 + t)                    # 0..1 smoothly
		jump_alpha = 1.0 - smoothstep(0.0, 1.0, t)
	else:
		if velocity.y > 0.0:
			velocity.y = 0.0
		jump_alpha = 0.0
		
		if Input.is_action_just_pressed("jump"):
			jump()
	
	# speed + rates
	var max_speed := sprint_speed if want_sprint else walk_speed

	var a := (air_sprint_accel if want_sprint else air_walk_accel) if not grounded else (sprint_accel if want_sprint else walk_accel)
	var d := (air_sprint_decel if want_sprint else air_walk_decel) if not grounded else (sprint_decel if want_sprint else walk_decel)
	var t := (air_sprint_turn_accel if want_sprint else air_walk_turn_accel) if not grounded else (sprint_turn_accel if want_sprint else walk_turn_accel)

	var target_speed := input_x * max_speed

	if want_move:
		var reversing = (velocity.x != 0.0) and (sign(target_speed) != sign(velocity.x))
		var rate := t if reversing else a
		velocity.x = move_toward(velocity.x, target_speed, rate * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, d * delta)

	move_and_slide()
	
	## ----------------------------
	## jump_alpha: smooth 0 -> 1 -> 0 based on vertical speed
	## 0 at jump start / fast fall, 1 near apex
	#var takeoff = max(1.0, abs(jump_velocity))
	#var j = abs(velocity.y) / takeoff       # 0..inf
	#j = j / (1.0 + j)                        # 0..1 (soft normalize)
	#jump_alpha = 1.0 - smoothstep(0.0, 1.0, j)
	## ----------------------------
	
	# animation
	var ratio = clamp(abs(velocity.x) / max_speed, 0.0, 1.0)
	anim_tree.set("parameters/IdleMove/blend_amount", float(ratio))
	anim_tree.set("parameters/WalkSprint/blend_amount", float(want_sprint))
	anim_tree.set("parameters/JumpApex/blend_amount", jump_alpha)
	
	if velocity.y >= 0 and grounded:
		can_jump = false


func jump() -> void:
	velocity.y -= jump_velocity


func fire(power: float, _owner: Node2D) -> void:
	var mouse_world := get_mouse_world()
	var rock_spawn = get_node(rock_spawn_point)

	var b := ROCK.instantiate() as Rock
	get_tree().current_scene.add_child(b)

	b.global_position = rock_spawn.global_position
	var v0 = compute_v0(b.global_position, mouse_world, power)
	
	print("power=", power)
	print("v0_len=", v0.length())
	b.launch(v0, _owner)


@export var power_max: float = 100.0     # your max power
@export var min_speed: float = 600.0     # speed at power = 0
@export var max_speed: float = 1800.0    # speed at power = 100 (or raise this)

func compute_v0(origin: Vector2, target: Vector2, power: float) -> Vector2:
	var dir := (target - origin).normalized()
	var t = clamp(power / power_max, 0.0, 1.0)  # normalize 0..100 -> 0..1
	var speed = lerp(min_speed, max_speed, t)
	return dir * speed


func is_moving_forward() -> bool:
	var move_dir = Input.get_axis("left", "right")
	
	if move_dir == 0:
		return false # Not moving

	# Mouse position in world space
	var mouse_pos = get_global_mouse_position()

	# Direction from player to mouse (horizontal only)
	var to_mouse = mouse_pos.x - global_position.x

	# Convert both to -1 or 1
	var mouse_dir = sign(to_mouse)

	return move_dir == mouse_dir


func get_mouse_world() -> Vector2:
	var vp := get_viewport()
	return vp.get_canvas_transform().affine_inverse() * vp.get_mouse_position()

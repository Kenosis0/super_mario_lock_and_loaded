extends CharacterBody2D

@onready var anim_tree: AnimationTree = $AnimationTree
@onready var shader_sprite: Sprite2D = $Render/ShaderSprite

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
var can_jump: bool = false
var is_falling: bool = false


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass
	#var mouse = get_global_mouse_position()
	#util.compute_mirrored_target(head_look_at, mouse, shader_sprite, subviewport)


func _physics_process(delta: float) -> void:
	input_x = Input.get_axis("left", "right")

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
	else:
		if velocity.y > 0.0:
			velocity.y = 0.0
		
		if Input.is_action_just_pressed("jump"):
			jump()
			#can_jump = true
			#print("should jump")

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

	# animation
	var ratio = clamp(abs(velocity.x) / max_speed, 0.0, 1.0)
	anim_tree.set("parameters/IdleMove/blend_amount", float(ratio))
	anim_tree.set("parameters/WalkSprint/blend_amount", float(want_sprint))
	
	
	#anim_tree.set("parameters/FallState/conditions/grounded", grounded)
	#
	#if can_jump:
		#anim_tree.set("parameters/OneShot/request", 1)
	
	if velocity.y >= 0 and grounded:
		can_jump = false


func jump() -> void:
	velocity.y -= jump_velocity

extends CharacterBody2D
class_name Goomba

const SCORE_POP = preload("uid://b2smavig5utf8")
const SMOKE_VFX = preload("uid://dxqibfxda0beg")

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var smoke_spawn_pos: Marker2D = $SmokeSpawnPos
@onready var move_on: Timer = $MoveOn
@onready var goomba_sprites: Node2D = get_node_or_null("GoombaSprites") as Node2D


@export var health: int = 3
@export var score_collected: int = 250

@export var gravity_weight: float = 5000

@export var speed := 50.0
@export var chase_speed: float = 200.0
@export var knockback_force := 450.0
@export var knockback_decay := 1400.0

var kb: Knockback
var current_health: int = health

var state_machine: StateMachine
var player: Player


signal damaged


func _ready() -> void:
	current_health = health
	kb = Knockback.new(knockback_force, knockback_decay)
	
	state_machine = GoombaFSM.new()
	
	var idle_state: GoombaIdleState = GoombaIdleState.new(self)
	var patrol_state: GoombaPatrolState = GoombaPatrolState.new(self)
	var chase_state: GoombaChaseState = GoombaChaseState.new(self)
	var stomp_state: GoombaStompState = GoombaStompState.new(self)
	var cooldown_state: GoombaCooldownState = GoombaCooldownState.new(self)
	
	state_machine.add_state("idle", idle_state)
	state_machine.add_state("patrol", patrol_state)
	state_machine.add_state("chase", chase_state)
	state_machine.add_state("stomp", stomp_state)
	state_machine.add_state("cooldown", cooldown_state)
	
	state_machine.set_initial_state("patrol")
	
	state_machine.set_owner_goomba(self)
	
	enter_goomba()


func _process(delta: float) -> void:
	if state_machine:
		state_machine.update(delta)
	
	update(delta)


func _physics_process(delta: float) -> void:
	if state_machine:
		state_machine.physics_update(delta)
	kb.update(delta)
	apply_gravity(delta)

	# Compose final velocity (no movement yet, so base is current velocity with gravity)
	var base := velocity
	base.x = 0.0 # since enemy has no movement yet

	velocity = base + kb.vel

	move_and_slide()
	update_physics(delta)


func enter_goomba() -> void:
	pass


func update(delta: float) -> void:
	pass


func update_physics(delta:float) -> void:
	pass


func apply_knockback(from_global_pos: Vector2, amount: float = -1.0) -> void:
	state_machine.change_state("idle")
	kb.apply_from(from_global_pos, global_position, amount)
	anim.play("hurt")
	if current_health >= 1:
		current_health -= 1
		if current_health == 0:
			die()
			return
	
	damaged.emit()


func die() -> void:
	AudioManager.play_sfx(AudioManager.DEADOOMPAS)
	var score: ScorePop = SCORE_POP.instantiate()
	score.score = score_collected
	GameManager.add_score(score_collected)
	get_tree().current_scene.add_child(score)
	score.global_position = self.global_position + Vector2(0, -50)

	_spawn_dead_rigidbody()
	queue_free()


func _spawn_dead_rigidbody() -> void:
	var source_scale := scale
	var dead_body := RigidBody2D.new()
	dead_body.name = "%s_Dead" % name
	dead_body.global_position = global_position
	dead_body.global_rotation = global_rotation
	dead_body.scale = Vector2.ONE
	dead_body.collision_layer = 0
	dead_body.collision_mask = 0
	
	var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
	if collision_shape:
		var dead_collision := collision_shape.duplicate() as CollisionShape2D
		if dead_collision:
			dead_collision.scale *= source_scale
			dead_body.add_child(dead_collision)

	var sprite_root := _get_sprite_root_for_death()
	if sprite_root:
		var copied_sprites := sprite_root.duplicate() as Node2D
		if copied_sprites:
			copied_sprites.scale *= source_scale
			dead_body.add_child(copied_sprites)
	else:
		push_warning("Goomba sprite root not found for %s" % name)

	get_tree().current_scene.add_child(dead_body)
	
	# Give the dead body a short pop so it feels like a defeat reaction.
	dead_body.apply_impulse(Vector2(randf_range(-140.0, 140.0), -420.0))
	dead_body.angular_velocity = randf_range(-6.0, 6.0)

	var cleanup_timer := Timer.new()
	cleanup_timer.one_shot = true
	cleanup_timer.wait_time = 5.0
	dead_body.add_child(cleanup_timer)
	cleanup_timer.timeout.connect(dead_body.queue_free)
	cleanup_timer.start()


func _get_sprite_root_for_death() -> Node2D:
	if is_instance_valid(goomba_sprites):
		return goomba_sprites

	var fallback := get_node_or_null("Goomba") as Node2D
	if fallback:
		return fallback

	return null


func apply_gravity(delta: float) -> void:
	var grounded = is_on_floor()
	if not grounded:
		velocity.y += gravity_weight * delta
		velocity.y = min(velocity.y, gravity_weight)
	else:
		if velocity.y > 0.0:
			velocity.y = 0.0


func play_animation(animation_name: String, speed_scale: float = 1) -> void:
	anim.play(animation_name, -1, speed_scale)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"enemy_detected":
			state_machine.change_state("chase")
		"cooldown":
			state_machine.change_state("idle")


func _on_player_detection_body_entered(body: Node2D) -> void:
	if body is Player and player == null:
		player = body
		state_machine.change_state("stomp")


func _on_attack_range_body_entered(body: Node2D) -> void:
	if body is Player:
		print("Hit player")
		body.apply_knockback(global_position, -10)
		move_on.stop()


func _on_player_detection_body_exited(body: Node2D) -> void:
	if body is Player:
		move_on.start()


func _on_move_on_timeout() -> void:
	player = null
	state_machine.change_state("cooldown")

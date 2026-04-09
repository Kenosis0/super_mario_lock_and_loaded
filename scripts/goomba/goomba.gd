extends CharacterBody2D
class_name Goomba

const GOOMBA_DEAD = preload("uid://csqd7wp56tecr")
const SCORE_POP = preload("uid://b2smavig5utf8")
const SMOKE_VFX = preload("uid://dxqibfxda0beg")

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var smoke_spawn_pos: Marker2D = $SmokeSpawnPos
@onready var move_on: Timer = $MoveOn


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


func _process(delta: float) -> void:
	if state_machine:
		state_machine.update(delta)


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


func apply_knockback(from_global_pos: Vector2, amount: float = -1.0) -> void:
	state_machine.change_state("idle")
	kb.apply_from(from_global_pos, global_position, amount)
	anim.play("hurt")
	if current_health >= 1:
		current_health -= 1
		if current_health == 0:
			die()


func die() -> void:
	var score: ScorePop = SCORE_POP.instantiate()
	score.score = score_collected
	GameManager.add_score(score_collected)
	get_tree().current_scene.add_child(score)
	score.global_position = self.global_position + Vector2(0, -50)
	
	var dead_goomba = GOOMBA_DEAD.instantiate()
	get_tree().current_scene.add_child(dead_goomba)
	dead_goomba.global_position = self.global_position
	queue_free()


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

extends CharacterBody2D
class_name Goomba

const GOOMBA_DEAD = preload("uid://csqd7wp56tecr")
const SCORE_POP = preload("uid://b2smavig5utf8")

@onready var anim: AnimationPlayer = $AnimationPlayer


@export var health: int = 3
@export var score_collected: int = 250

@export var gravity_weight: float = 5000

@export var speed := 200.0
@export var knockback_force := 450.0
@export var knockback_decay := 1400.0

var kb: Knockback
var current_health: int = health

func _ready() -> void:
	current_health = health
	anim.play("idle")
	kb = Knockback.new(knockback_force, knockback_decay)
	print("mask: ", get_collision_mask_value(4))


func _physics_process(delta: float) -> void:
	kb.update(delta)
	apply_gravity(delta)

	# Compose final velocity (no movement yet, so base is current velocity with gravity)
	var base := velocity
	base.x = 0.0 # since enemy has no movement yet

	velocity = base + kb.vel

	move_and_slide()


func apply_knockback(from_global_pos: Vector2, amount: float = -1.0) -> void:
	set_collision_mask_value(4, false)
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


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hurt":
		set_collision_mask_value(4, true)

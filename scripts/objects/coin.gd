extends Area2D
class_name Coin

@export var score_value: int = 100

@onready var _anim: AnimationPlayer = $AnimationPlayer
@onready var _sprite: Sprite2D = $Sprite2D



func _on_body_entered(body: Node) -> void:
	if body is Player:
		print("player")
		# Prevent double-collection
		set_deferred("monitoring", false)
		_anim.stop()
		GameManager.add_score(score_value)
		_play_pickup_anim()


func _play_pickup_anim() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_sprite, "position", _sprite.position + Vector2(0, -55), 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(_sprite, "modulate:a", 0.0, 0.45)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(_sprite, "scale", Vector2(1.3, 1.3), 0.2)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished
	queue_free()

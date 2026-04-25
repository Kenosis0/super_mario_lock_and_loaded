extends Area2D
class_name Coin

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# Play animations of the coin
	animated_sprite_2d.play("default")
	animation_player.play("hover")


func _on_body_entered(body: Node2D) -> void:
	# If player is detected, animation collected is played and add score to the player
	if body is Player:
		animation_player.play("collected")
		AudioManager.play_sfx(AudioManager.COINCOLLECTSFX)
		GameManager.add_score(1)


# After playing the collected animation queue free the coin from the scene
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()

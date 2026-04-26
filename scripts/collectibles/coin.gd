extends Area2D
class_name Coin

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export_enum("Bronze", "Silver", "Gold") var coin_type: String = "Bronze":
	get = get_coin_type

func _ready() -> void:
	# Play animations of the coin
	animated_sprite_2d.play("default")
	animation_player.play("hover")
	
	modulate = get_color_on_coin_type()


func get_coin_type() -> String:
	return coin_type


func get_color_on_coin_type() -> Color: 
	print("Chaging color to: ", coin_type)
	match coin_type:
		"Bronze":
			return Color(0.729, 0.357, 0.0, 1.0)
		"Silver":
			return Color(1.0, 1.0, 1.0, 1.0)
		"Gold":
			return Color(1.0, 1.0, 0.0, 1.0)
		_:
			return Color()


func _on_body_entered(body: Node2D) -> void:
	# If player is detected, animation collected is played and add coin count by type.
	if body is Player:
		animation_player.play("collected")
		AudioManager.play_sfx(AudioManager.COINCOLLECTSFX)
		GameManager.add_coin(coin_type)


# After playing the collected animation queue free the coin from the scene
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()

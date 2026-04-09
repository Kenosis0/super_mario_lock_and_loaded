extends GoombaStateInterface
class_name GoombaStompState


func enter(prev_state: String) -> void:
	goomba.play_animation("enemy_detected")

extends GoombaStateInterface
class_name GoombaCooldownState


func enter(prev_state: String) -> void:
	goomba.play_animation("cooldown")

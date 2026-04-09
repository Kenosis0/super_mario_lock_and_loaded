extends GoombaStateInterface
class_name GoombaChaseState

var player: Player

func enter(_prev_state: String) -> void:
	if goomba.player:
		player = goomba.player
	else:
		state_machine.change_state("idle")
		return

func update(_delta: float) -> void:
	goomba.play_animation("move", 1.5)


func physics_update(_delta: float) -> void:
	var dir_x = player.global_position.x - goomba.global_position.x
	goomba.velocity.x = sign(dir_x) * goomba.chase_speed
	goomba.move_and_slide()

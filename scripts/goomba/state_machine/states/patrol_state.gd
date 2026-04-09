extends GoombaStateInterface
class_name GoombaPatrolState


var patrol_timer: float = 10.5
var min_wait_time: float = 5.0
var timer: float = 0.0
var dir_x: int

func enter(prev_state: String) -> void:
	print("Goomba Patrol State Entered")
	var dir_arr: Array = [1,-1]
	dir_x = dir_arr.pick_random()
	timer = randf_range(min_wait_time, patrol_timer)
	
	goomba.play_animation("move")


func update(delta: float) -> void:
	if timer <= 0.0:
		_time_out()
	else:
		timer -= delta
		_timer_active()


func physics_update(delta: float) -> void:
	goomba.velocity.x = dir_x * goomba.speed
	goomba.move_and_slide()


func _time_out() -> void:
	state_machine.change_state("idle")


func _timer_active() -> void:
	pass

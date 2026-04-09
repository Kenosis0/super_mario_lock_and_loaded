extends GoombaStateInterface
class_name GoombaIdleState

var idle_timer: float = 10.0
var min_wait_time: float = 4.5
var _timer: float = 0.0


func enter(prev_state: String) -> void:
	_timer = randf_range(min_wait_time, idle_timer)


func exit() -> void:
	# Called when the state is exited
	pass


func update(delta: float) -> void:
	goomba.play_animation("idle")
	if _timer > 0:
		_timer -= delta
	else:
		_timeout()


func physics_update(delta: float) -> void:
	goomba.velocity.x = 0


func _timeout() -> void:
	state_machine.change_state("patrol")

# meta_name: StateInterface Class
# meta_description: An interface for defining states in a state machine. Each state should implement the enter, exit, and update methods.

extends RefCounted
class_name StateInterface

var state_machine: StateMachine

func enter(prev_state: String) -> void:
	# Called when the state is entered
	pass

func exit() -> void:
	# Called when the state is exited
	pass

func update(delta: float) -> void:
	# Called every frame while the state is active
	pass

func physics_update(delta: float) -> void:
	# Called every physics frame update
	pass

func handle_input(event: InputEvent) -> void:
	# Called when an input event is received
	pass

extends RefCounted
class_name StateMachine

var states: Dictionary = {}
var current_state: StateInterface
var current_state_name: String = ""
var owner: Node


func add_state(state_name: String, state: StateInterface) -> void:
	states[state_name] = state
	state.state_machine = self


func set_initial_state(state_name: String) -> void:
	if states.has(state_name):
		current_state = states[state_name]
		current_state_name = state_name
		current_state.enter("")
	else:
		push_error("State '%s' does not exist in the state machine." % state_name)


func change_state(new_state_name: String) -> void:
	var prev_state_name = current_state_name

	if current_state:
		current_state.exit()
	
	current_state_name = new_state_name
	current_state = states.get(new_state_name)

	if current_state:
		current_state.enter(prev_state_name)
	else:
		push_error("State '%s' does not exist in the state machine." % new_state_name)


func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func handle_input(event: InputEvent) -> void:
	if current_state:     
		current_state.handle_input(event)


func get_current_state_name() -> String:
	return current_state_name

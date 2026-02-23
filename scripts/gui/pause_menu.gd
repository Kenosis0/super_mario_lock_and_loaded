extends PanelContainer
class_name PauseMenu


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	hide()


func _process(_delta: float) -> void:
	if get_tree().is_paused():
		show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

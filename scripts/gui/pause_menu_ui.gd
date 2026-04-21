extends CanvasLayer


func _on_resume_button_pressed() -> void:
	get_tree().set_pause(false)
	queue_free()


func _on_mainmenu_button_pressed() -> void:
	pass # Replace with function body.

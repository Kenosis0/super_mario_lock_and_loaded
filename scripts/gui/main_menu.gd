extends Control


func _ready() -> void:
	# Animate title on entry
	var title: Label = $CenterContainer/Panel/VBox/Title
	title.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(title, "modulate:a", 1.0, 1.2).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(title, "position:y", title.position.y, 0.8)\
		.from(title.position.y - 30.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Stagger button entry
	for btn in [$CenterContainer/Panel/VBox/PlayButton,
				$CenterContainer/Panel/VBox/QuitButton]:
		btn.modulate.a = 0.0

	var delay := 0.5
	for btn in [$CenterContainer/Panel/VBox/PlayButton,
				$CenterContainer/Panel/VBox/QuitButton]:
		var t2 := create_tween()
		t2.tween_interval(delay)
		t2.tween_property(btn, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE)
		delay += 0.2


func _on_play_button_pressed() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_quit_button_pressed() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE)
	await tween.finished
	get_tree().quit()

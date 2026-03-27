extends Control

@onready var title: Label = %Title
@onready var play_button: Button = %PlayButton
@onready var exit_button: Button = %ExitButton
@onready var fade_rect: ColorRect = %FadeRect
@onready var content: VBoxContainer = %Content

var _title_base_y: float

func _ready() -> void:
	#play_button.connect("mouse_entered", Callable(self, "_button_hover_scale").bind(play_button, true))
	play_button.mouse_entered.connect(func(): _button_hover_scale(play_button, true))
	play_button.mouse_exited.connect(func(): _button_hover_scale(play_button, false))
	exit_button.mouse_entered.connect(func(): _button_hover_scale(exit_button, true))
	exit_button.mouse_exited.connect(func(): _button_hover_scale(exit_button, false))
	_play_intro()


func _play_intro() -> void:
	# Start hidden
	fade_rect.color = Color(0, 0, 0, 1)
	title.modulate.a = 0.0
	title.pivot_offset = title.size / 2.0
	title.scale = Vector2(0.6, 0.6)
	play_button.modulate.a = 0.0
	exit_button.modulate.a = 0.0

	var tween := create_tween().set_parallel(true)

	# Fade from black
	tween.tween_property(fade_rect, "color:a", 0.0, 1.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	# Title drops in with scale bounce
	tween.tween_property(title, "modulate:a", 1.0, 0.8).set_delay(0.4)
	tween.tween_property(title, "scale", Vector2.ONE, 0.7).set_delay(0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# Buttons slide in
	tween.tween_property(play_button, "modulate:a", 1.0, 0.5).set_delay(0.9)
	tween.tween_property(exit_button, "modulate:a", 1.0, 0.5).set_delay(1.15)

	await tween.finished

	# Start gentle title float
	_animate_title_float()


func _animate_title_float() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(title, "position:y", title.position.y - 8.0, 1.8) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(title, "position:y", title.position.y + 8.0, 1.8) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


func _button_hover_scale(btn: Button, hovered: bool) -> void:
	var target_scale := Vector2(1.08, 1.08) if hovered else Vector2.ONE
	btn.pivot_offset = btn.size / 2.0
	var tween := create_tween()
	tween.tween_property(btn, "scale", target_scale, 0.12).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func _on_play_pressed() -> void:
	# Transition out then load level
	var tween := create_tween()
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	tween.tween_property(fade_rect, "color:a", 1.0, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()

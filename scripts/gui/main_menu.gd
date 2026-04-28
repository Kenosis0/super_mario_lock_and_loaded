extends Control

const LEVEL_SELECT_UI := "res://scenes/UI/level_select.tscn"
const SETTINGS_UI := "res://scenes/UI/settings.tscn"

@onready var title: Label = %Title
@onready var content: VBoxContainer = %Content
@onready var buttons: VBoxContainer = %Buttons
@onready var continue_button: Button = $Content/MarginContainer/Buttons/ContinueButton

var _title_base_y: float


func _ready() -> void:
	AudioManager.play_bgm(AudioManager.MENU_MUSICBGMTEST_2)
	for button in buttons.get_children():
		if button is Button:
			if not button.is_connected("pressed", Callable(self, "_on_menu_button_pressed").bind(button.text.to_lower())):
				button.connect("pressed", Callable(self, "_on_menu_button_pressed").bind(button.text.to_lower()))

	continue_button.visible = GameManager.has_continue_data()

func _on_menu_button_pressed(button_name: String) -> void:
	match button_name:
		"continue":
			_on_continue_button_pressed()
		"new game":
			_on_newgame_button_pressed()
		"select level":
			_on_selectlevel_button_pressed()
		"settings":
			_on_setting_button_pressed()
		"quit game":
			_on_quit_button_pressed()


func _on_continue_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.BUTTONCLICK)
	GameManager.continue_game()


func _on_newgame_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.BUTTONCLICK)
	GameManager.new_level()


func _on_selectlevel_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.BUTTONCLICK)
	get_tree().change_scene_to_file(LEVEL_SELECT_UI)


func _on_setting_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.BUTTONCLICK)
	get_tree().change_scene_to_file(SETTINGS_UI)


func _on_quit_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.BUTTONCLICK)
	get_tree().quit()


#func _play_intro() -> void:
	## Start hidden
	#fade_rect.color = Color(0, 0, 0, 1)
	#title.modulate.a = 0.0
	#title.pivot_offset = title.size / 2.0
	#title.scale = Vector2(0.6, 0.6)
	#play_button.modulate.a = 0.0
	#exit_button.modulate.a = 0.0
#
	#var tween := create_tween().set_parallel(true)
#
	## Fade from black
	#tween.tween_property(fade_rect, "color:a", 0.0, 1.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
#
	## Title drops in with scale bounce
	#tween.tween_property(title, "modulate:a", 1.0, 0.8).set_delay(0.4)
	#tween.tween_property(title, "scale", Vector2.ONE, 0.7).set_delay(0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
#
	## Buttons slide in
	#tween.tween_property(play_button, "modulate:a", 1.0, 0.5).set_delay(0.9)
	#tween.tween_property(exit_button, "modulate:a", 1.0, 0.5).set_delay(1.15)
#
	#await tween.finished
#
	## Start gentle title float
	#_animate_title_float()


#func _animate_title_float() -> void:
	#var tween := create_tween().set_loops()
	#tween.tween_property(title, "position:y", title.position.y - 8.0, 1.8) \
		#.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	#tween.tween_property(title, "position:y", title.position.y + 8.0, 1.8) \
		#.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


#func _button_hover_scale(btn: Button, hovered: bool) -> void:
	#var target_scale := Vector2(1.08, 1.08) if hovered else Vector2.ONE
	#btn.pivot_offset = btn.size / 2.0
	#var tween := create_tween()
	#tween.tween_property(btn, "scale", target_scale, 0.12).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
#

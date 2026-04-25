extends Control
class_name LevelSelectUI

@onready var level_buttons: VBoxContainer = %LevelButtons
@onready var back_button: Button = %BackButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_level_buttons()
	back_button.pressed.connect(_on_back_pressed)


func _build_level_buttons() -> void:
	for child in level_buttons.get_children():
		child.queue_free()

	for i in range(GameManager.levels.size()):
		var button := Button.new()
		button.text = "LEVEL %d" % (i + 1)
		button.theme = load("res://resources/button_theme.tres")
		button.custom_minimum_size = Vector2(360, 64)
		button.pressed.connect(_on_level_pressed.bind(i))
		level_buttons.add_child(button)


func _on_level_pressed(level_index: int) -> void:
	AudioManager.play_sfx(AudioManager.BUTTONCLICK)
	GameManager.current_level = level_index
	GameManager.new_level()


func _on_back_pressed() -> void:
	AudioManager.play_sfx(AudioManager.BUTTONCLICK)
	GameManager.return_to_main_menu()

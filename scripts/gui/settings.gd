extends Control
class_name SettingsUI

const MAIN_MENU_UI := "res://scenes/UI/main_menu.tscn"
const PANEL_FOCUS = preload("uid://dj124eosd2xh4")
const PANEL_UN_FOCUS = preload("uid://b4283py8xp65b")


@onready var master_slider: HSlider = %MasterSlider
@onready var master_value_label: Label = %MasterValueLabel
@onready var bgm_slider: HSlider = %BGMSlider
@onready var bgm_value_label: Label = %BGMValueLabel
@onready var sfx_slider: HSlider = %SFXSlider
@onready var sfx_value_label: Label = %SFXValueLabel
@onready var back_button: Button = %BackButton
@onready var master_panel: PanelContainer = $"CenterContainer/PanelContainer/MarginContainer/VBox/PanelContainer"
@onready var bgm_panel: PanelContainer = $"CenterContainer/PanelContainer/MarginContainer/VBox/PanelContainer2"
@onready var sfx_panel: PanelContainer = $"CenterContainer/PanelContainer/MarginContainer/VBox/PanelContainer3"

var setting_panels: Array[PanelContainer] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	master_slider.value = AudioManager.get_master_volume_linear()
	bgm_slider.value = AudioManager.get_bgm_volume_linear()
	sfx_slider.value = AudioManager.get_sfx_volume_linear()
	_update_value_labels()

	master_slider.value_changed.connect(_on_master_slider_changed)
	bgm_slider.value_changed.connect(_on_bgm_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	back_button.pressed.connect(_on_back_pressed)

	setting_panels = [master_panel, bgm_panel, sfx_panel]
	_set_active_panel(null)

	master_slider.focus_entered.connect(_on_slider_focus_entered.bind(master_panel))
	bgm_slider.focus_entered.connect(_on_slider_focus_entered.bind(bgm_panel))
	sfx_slider.focus_entered.connect(_on_slider_focus_entered.bind(sfx_panel))

	master_slider.drag_started.connect(_on_slider_drag_started.bind(master_panel))
	bgm_slider.drag_started.connect(_on_slider_drag_started.bind(bgm_panel))
	sfx_slider.drag_started.connect(_on_slider_drag_started.bind(sfx_panel))

	master_slider.drag_ended.connect(_on_slider_drag_ended)
	bgm_slider.drag_ended.connect(_on_slider_drag_ended)
	sfx_slider.drag_ended.connect(_on_slider_drag_ended)


func _on_master_slider_changed(value: float) -> void:
	_set_active_panel(master_panel)
	AudioManager.set_master_volume_linear(value)
	AudioManager.save_audio_settings()
	_update_value_labels()


func _on_bgm_slider_changed(value: float) -> void:
	_set_active_panel(bgm_panel)
	AudioManager.set_bgm_volume_linear(value)
	AudioManager.save_audio_settings()
	_update_value_labels()


func _on_sfx_slider_changed(value: float) -> void:
	_set_active_panel(sfx_panel)
	AudioManager.set_sfx_volume_linear(value)
	AudioManager.save_audio_settings()
	_update_value_labels()


func _on_back_pressed() -> void:
	AudioManager.play_sfx(AudioManager.BUTTONCLICK)
	AudioManager.save_audio_settings()
	get_tree().change_scene_to_file(MAIN_MENU_UI)


func _update_value_labels() -> void:
	master_value_label.text = "%d%%" % int(round(master_slider.value * 100.0))
	bgm_value_label.text = "%d%%" % int(round(bgm_slider.value * 100.0))
	sfx_value_label.text = "%d%%" % int(round(sfx_slider.value * 100.0))


func _on_slider_focus_entered(panel: PanelContainer) -> void:
	_set_active_panel(panel)


func _on_slider_drag_started(panel: PanelContainer) -> void:
	_set_active_panel(panel)


func _on_slider_drag_ended(_value_changed: bool) -> void:
	if master_slider.has_focus() or bgm_slider.has_focus() or sfx_slider.has_focus():
		return
	_set_active_panel(null)


func _set_active_panel(active_panel: PanelContainer) -> void:
	for panel in setting_panels:
		panel.theme = PANEL_FOCUS if panel == active_panel else PANEL_UN_FOCUS

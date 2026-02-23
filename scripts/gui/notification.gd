extends PanelContainer
class_name NotificationUI

@onready var label_notification: RichTextLabel = $LabelNotification
@onready var timer_ui: TimerUI = $"../TimerUI"

var win_text: String = "You WIN!"
var lose_text: String = "You LOSE!"

var first_play: bool = false


func _ready() -> void:
	show()
	GameManager.notification_ui = self
	get_tree().set_pause(true)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and first_play == false:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			get_tree().set_pause(false)
			label_notification.text = ""
			first_play = true
			timer_ui.start()
			hide()

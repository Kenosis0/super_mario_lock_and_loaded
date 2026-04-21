extends Node

var game_timer: TimerUI
var notification_ui: NotificationUI
var score_label: Label
var score: int = 0
var goal_score: int = 3750

var goal_reached: bool = false
var timer_finished: bool = false

var levels: Array[String] = [
	"uid://bxyeclsiraagj"
]
var current_level: int = 0


func _ready() -> void:
	set_process_mode(Node.PROCESS_MODE_ALWAYS)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		if not get_tree().is_paused():
			print("pausing")
			get_tree().set_pause(true)
		else:
			print("playing")
			get_tree().set_pause(false)


func add_score(amount: int) -> void:
	if score_label:
		score += amount
		score_label.text = "%06d" % score
	
	if score >= goal_score:
		if game_timer:
			game_timer.pause()
		if notification_ui:
			notification_ui.label_notification.text = notification_ui.win_text
			notification_ui.show()
			get_tree().set_pause(true)
		goal_reached = true


func get_level() -> PackedScene:
	var level: PackedScene = null
	var path = levels.get(current_level)
	
	if path.length() > 0:
		return load(path)
	
	return level

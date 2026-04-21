extends Node

const PAUSE_MENU_UI = preload("uid://dug8bovqvdk2m")
const LEVEL_HUD = preload("uid://bxdk8rhcjsk6e")

var pause_ui
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
var level_datas: Array[LevelData]

var current_level: int = 0
var level_started: bool = false

func _ready() -> void:
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	
	for i in range(levels.size()):
		var instance = load(levels.get(i)).instantiate()
		if instance is LevelInterface:
			level_datas.append(instance.level_data)


func _input(event: InputEvent) -> void:
	if not level_started:
		return
	if Input.is_action_just_pressed("pause"):
		if not get_tree().is_paused():
			var pause = PAUSE_MENU_UI.instantiate()
			get_tree().current_scene.add_child(pause)
			print("pausing")
			get_tree().set_pause(true)
			pause_ui = pause
		else:
			print("playing")
			pause_ui.queue_free()
			get_tree().set_pause(false)


func add_score(amount: int) -> void:
	score += amount
	
	if score >= goal_score:
		if game_timer:
			game_timer.pause()
		if notification_ui:
			notification_ui.label_notification.text = notification_ui.win_text
			notification_ui.show()
			get_tree().set_pause(true)
		goal_reached = true
	
	print("Added amount: ", amount)
	print("current score: ", score)


func get_level() -> PackedScene:
	var level: PackedScene = null
	var path = levels.get(current_level)
	
	if path.length() > 0:
		level = load(path)
		return load(path)
	
	return level


func new_level() -> void:
	var level = get_level()
	
	
	score = 0
	goal_reached = false
	
	if level:
		get_tree().change_scene_to_packed(level)

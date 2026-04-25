extends Node

signal score_changed(new_score: int, goal_score: int)

const PAUSE_MENU_UI = preload("uid://dug8bovqvdk2m")
const LEVEL_HUD = preload("uid://bxdk8rhcjsk6e")
const LEVEL_END_UI = preload("res://scenes/UI/level_end.tscn")
const MAIN_MENU_UI = preload("res://scenes/UI/main_menu.tscn")
const LEVEL_2 = preload("uid://ckg45c8hq2yo4")

var pause_ui
var game_timer: TimerUI
var notification_ui: NotificationUI
var score_label: Label
var score: int = 0
var goal_score: int = 3750
var level_time_limit: float = 0.0

var goal_reached: bool = false
var timer_finished: bool = false
var current_level_data: LevelData
var last_level_result: LevelEndResult

var levels: Array[String] = [
	"uid://bxyeclsiraagj",
	"uid://ckg45c8hq2yo4"
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


func register_game_timer(timer: TimerUI) -> void:
	game_timer = timer
	if game_timer:
		level_time_limit = game_timer.time
		if not game_timer.finished.is_connected(_on_timer_finished):
			game_timer.finished.connect(_on_timer_finished)
		if not game_timer.bonus_finished.is_connected(_on_bonus_finished):
			game_timer.bonus_finished.connect(_on_bonus_finished)


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
	if amount <= 0:
		return

	score += amount
	emit_signal("score_changed", score, goal_score)
	
	if score >= goal_score:
		begin_bonus_phase()
	
	print("Added amount: ", amount)
	print("current score: ", score)


func add_bonus_score(amount: int) -> void:
	if amount <= 0:
		return

	score += amount
	emit_signal("score_changed", score, goal_score)


func begin_bonus_phase() -> void:
	if goal_reached:
		return

	goal_reached = true
	if game_timer:
		game_timer.start_score_bonus()
	get_tree().paused = true


func _on_timer_finished() -> void:
	if goal_reached:
		return

	timer_finished = true
	finish_level(false)


func _on_bonus_finished() -> void:
	finish_level(true)


func finish_level(won: bool) -> void:
	var level_data := current_level_data
	if level_data == null and current_level < level_datas.size():
		level_data = level_datas[current_level]
	if level_data:
		level_data.current_score = score

	var time_bonus := 0
	if won:
		time_bonus = max(score - goal_score, 0)

	var total_time_bonus := int(round(level_time_limit * 100.0))
	var max_score := goal_score + total_time_bonus
	var percent := 0.0
	if max_score > 0:
		percent = (float(score) / float(max_score)) * 100.0

	var result := LevelEndResult.new()
	result.level_id = level_data.level_id if level_data else current_level + 1
	result.won = won
	result.score_objective = goal_score
	result.time_bonus = time_bonus
	result.max_time_bonus = total_time_bonus
	result.total_score = score
	result.max_score = max_score
	result.percent = percent
	result.grade = _grade_from_percent(percent)
	last_level_result = result

	level_started = false
	get_tree().paused = false
	call_deferred("_change_to_level_end")


func _change_to_level_end() -> void:
	if LEVEL_END_UI:
		get_tree().change_scene_to_packed(LEVEL_END_UI)


func restart_current_level() -> void:
	level_started = false
	get_tree().paused = false
	var level := get_level()
	if level:
		get_tree().change_scene_to_packed(level)


func return_to_main_menu() -> void:
	level_started = false
	get_tree().paused = false
	get_tree().change_scene_to_packed(MAIN_MENU_UI)


func get_level() -> PackedScene:
	var level: PackedScene = null
	var path = levels.get(current_level)
	
	if path == null:
		return null
	
	if path.length() > 0:
		level = load(path)
		return load(path)
	
	return level


func new_level() -> void:
	var level = get_level()
	
	
	score = 0
	emit_signal("score_changed", score, goal_score)
	goal_reached = false
	timer_finished = false
	
	if level:
		get_tree().change_scene_to_packed(level)

func has_next_level() -> bool:
	return (current_level + 1) < levels.size()

func next_level() -> void:
	if not has_next_level():
		return

	level_started = false
	get_tree().paused = false
	current_level += 1
	new_level()


func _grade_from_percent(percent: float) -> String:
	if percent >= 95.0:
		return "SSS"
	if percent >= 90.0:
		return "SS"
	if percent >= 80.0:
		return "S"
	if percent >= 70.0:
		return "A"
	if percent >= 60.0:
		return "B"
	if percent >= 50.0:
		return "C"
	if percent >= 40.0:
		return "D"
	return "F"

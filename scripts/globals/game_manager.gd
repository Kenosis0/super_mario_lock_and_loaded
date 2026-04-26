extends Node

signal score_changed(new_score: int, goal_score: int)
signal coin_counts_changed(bronze_count: int, silver_count: int, gold_count: int)

const CRTFILTER = preload("uid://rklc4ekfkqm")

const COIN_TYPE_BRONZE := "Bronze"
const COIN_TYPE_SILVER := "Silver"
const COIN_TYPE_GOLD := "Gold"

const BRONZE_COIN_POINTS := 10
const SILVER_COIN_POINTS := 100
const GOLD_COIN_POINTS := 500

const PAUSE_MENU_UI = preload("uid://dug8bovqvdk2m")
const LEVEL_HUD = preload("uid://bxdk8rhcjsk6e")
const LEVEL_END_UI = preload("res://scenes/UI/level_end.tscn")
const MAIN_MENU_UI = preload("res://scenes/UI/main_menu.tscn")
const LEVEL_2 = preload("uid://ckg45c8hq2yo4")

var pause_ui
var game_timer: TimerUI
var _continue_prompt_layer: CanvasLayer
var _continue_prompt_label: Label
var _awaiting_bonus_continue: bool = false
var _bonus_continue_requested: bool = false
var _has_continue_data: bool = false
var _continue_level_index: int = -1
var _continue_score: int = 0
var _continue_remaining_time: float = -1.0
var _continue_player_position: Vector2 = Vector2.ZERO
var _has_continue_player_position: bool = false
var _pending_resume_time: float = -1.0
var _pending_resume_player_position: Vector2 = Vector2.ZERO
var _has_pending_resume_player_position: bool = false
var score: int = 0
var goal_score: int = 3750
var level_time_limit: float = 0.0
var bronze_coin_count: int = 0
var silver_coin_count: int = 0
var gold_coin_count: int = 0

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
	
	var crtfilter = CRTFILTER.instantiate()
	add_child(crtfilter)


func register_game_timer(timer: TimerUI) -> void:
	game_timer = timer
	if game_timer:
		level_time_limit = game_timer.time
		if _pending_resume_time >= 0.0:
			game_timer.reset(_pending_resume_time)
			game_timer.start()
			_pending_resume_time = -1.0
		if not game_timer.finished.is_connected(_on_timer_finished):
			game_timer.finished.connect(_on_timer_finished)
		if not game_timer.bonus_finished.is_connected(_on_bonus_finished):
			game_timer.bonus_finished.connect(_on_bonus_finished)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and goal_reached:
		if game_timer and game_timer.is_bonus_active():
			if not _bonus_continue_requested:
				_bonus_continue_requested = true
				game_timer.skip_score_bonus()
			get_viewport().set_input_as_handled()
			return
		if _awaiting_bonus_continue:
			finish_level(true)
			get_viewport().set_input_as_handled()
			return

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


func add_coin(coin_type: String) -> void:
	match coin_type:
		COIN_TYPE_BRONZE:
			bronze_coin_count += 1
		COIN_TYPE_SILVER:
			silver_coin_count += 1
		COIN_TYPE_GOLD:
			gold_coin_count += 1
		_:
			push_warning("Unknown coin type: %s" % coin_type)
			return

	emit_signal("coin_counts_changed", bronze_coin_count, silver_coin_count, gold_coin_count)


func get_coin_bonus_score() -> int:
	return (
		bronze_coin_count * BRONZE_COIN_POINTS
		+ silver_coin_count * SILVER_COIN_POINTS
		+ gold_coin_count * GOLD_COIN_POINTS
	)


func reset_coin_counts() -> void:
	bronze_coin_count = 0
	silver_coin_count = 0
	gold_coin_count = 0
	emit_signal("coin_counts_changed", bronze_coin_count, silver_coin_count, gold_coin_count)


func begin_bonus_phase() -> void:
	if goal_reached:
		return

	goal_reached = true
	_awaiting_bonus_continue = false
	_bonus_continue_requested = false
	_show_continue_prompt()
	if game_timer:
		game_timer.start_score_bonus()
	get_tree().paused = true


func _on_timer_finished() -> void:
	if goal_reached:
		return

	timer_finished = true
	finish_level(false)


func _on_bonus_finished() -> void:
	if _bonus_continue_requested:
		finish_level(true)
		return

	_awaiting_bonus_continue = true
	get_tree().paused = true


func finish_level(won: bool) -> void:
	_hide_continue_prompt()
	_awaiting_bonus_continue = false
	_bonus_continue_requested = false
	clear_continue_data()

	if not won:
		var projected_score := score + get_coin_bonus_score()
		if projected_score >= goal_score:
			won = true

	var level_data := current_level_data
	if level_data == null and current_level < level_datas.size():
		level_data = level_datas[current_level]
	if level_data:
		level_data.current_score = score
		level_data.level_started = false

	var score_before_coin_bonus := score
	if won:
		var coin_bonus := get_coin_bonus_score()
		if coin_bonus > 0:
			add_bonus_score(coin_bonus)

	var time_bonus := 0
	if won:
		time_bonus = max(score_before_coin_bonus - goal_score, 0)

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
	_awaiting_bonus_continue = false
	_bonus_continue_requested = false
	_pending_resume_time = -1.0
	_has_pending_resume_player_position = false
	_hide_continue_prompt()
	clear_continue_data()
	if current_level < level_datas.size() and level_datas[current_level]:
		level_datas[current_level].current_score = 0
		level_datas[current_level].level_started = false
	reset_coin_counts()
	score = 0
	emit_signal("score_changed", score, goal_score)
	var level := get_level()
	if level:
		get_tree().change_scene_to_packed(level)


func return_to_main_menu(save_progress: bool = false) -> void:
	if save_progress:
		save_continue_data_from_current_run()
	else:
		clear_continue_data()

	level_started = false
	get_tree().paused = false
	_awaiting_bonus_continue = false
	_bonus_continue_requested = false
	_pending_resume_time = -1.0
	_hide_continue_prompt()
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
	_pending_resume_time = -1.0
	_has_pending_resume_player_position = false
	_awaiting_bonus_continue = false
	_bonus_continue_requested = false
	_hide_continue_prompt()
	clear_continue_data()
	if current_level < level_datas.size() and level_datas[current_level]:
		level_datas[current_level].current_score = 0
		level_datas[current_level].level_started = false
	reset_coin_counts()
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
	clear_continue_data()
	current_level += 1
	new_level()


func has_continue_data() -> bool:
	return _has_continue_data and _continue_level_index >= 0 and _continue_level_index < levels.size()


func continue_game() -> void:
	if not has_continue_data():
		return

	current_level = _continue_level_index
	score = _continue_score
	emit_signal("score_changed", score, goal_score)
	_pending_resume_time = max(_continue_remaining_time, 0.0)
	if _has_continue_player_position:
		_pending_resume_player_position = _continue_player_position
		_has_pending_resume_player_position = true
	else:
		_has_pending_resume_player_position = false
	goal_reached = false
	timer_finished = false
	_awaiting_bonus_continue = false
	_bonus_continue_requested = false
	_hide_continue_prompt()

	if current_level < level_datas.size() and level_datas[current_level]:
		level_datas[current_level].current_score = score
		level_datas[current_level].level_started = true

	var level := get_level()
	if level:
		get_tree().change_scene_to_packed(level)


func save_continue_data_from_current_run() -> void:
	if not level_started:
		return
	if current_level < 0 or current_level >= level_datas.size():
		return

	var remaining_time := level_time_limit
	if game_timer:
		remaining_time = game_timer.get_remaining_time()

	_continue_level_index = current_level
	_continue_score = score
	_continue_remaining_time = max(remaining_time, 0.0)
	_has_continue_player_position = false

	var scene_root := get_tree().current_scene
	if scene_root:
		var player_node := scene_root.get_node_or_null("Player") as Node2D
		if player_node:
			_continue_player_position = player_node.global_position
			_has_continue_player_position = true
	_has_continue_data = true

	var level_data := level_datas[current_level]
	if level_data:
		level_data.current_score = score
		level_data.level_started = true


func clear_continue_data() -> void:
	_has_continue_data = false
	_continue_level_index = -1
	_continue_score = 0
	_continue_remaining_time = -1.0
	_continue_player_position = Vector2.ZERO
	_has_continue_player_position = false
	_pending_resume_player_position = Vector2.ZERO
	_has_pending_resume_player_position = false


func apply_pending_resume_player_position(player: Node2D) -> void:
	if not _has_pending_resume_player_position:
		return
	if player == null:
		return

	player.global_position = _pending_resume_player_position
	_has_pending_resume_player_position = false


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


func _show_continue_prompt() -> void:
	if _continue_prompt_layer:
		return
	if get_tree().current_scene == null:
		return

	_continue_prompt_layer = CanvasLayer.new()
	_continue_prompt_layer.layer = 100
	_continue_prompt_layer.process_mode = Node.PROCESS_MODE_ALWAYS

	var dim_bg := ColorRect.new()
	dim_bg.color = Color(0.0, 0.0, 0.0, 0.35)
	dim_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim_bg.offset_left = 0.0
	dim_bg.offset_top = 0.0
	dim_bg.offset_right = 0.0
	dim_bg.offset_bottom = 0.0
	_continue_prompt_layer.add_child(dim_bg)

	_continue_prompt_label = Label.new()
	_continue_prompt_label.text = "Press any keys to continue"
	_continue_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_continue_prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_continue_prompt_label.set_anchors_preset(Control.PRESET_CENTER)
	_continue_prompt_label.offset_left = -540.0
	_continue_prompt_label.offset_right = 540.0
	_continue_prompt_label.offset_top = -60.0
	_continue_prompt_label.offset_bottom = 60.0
	_continue_prompt_label.add_theme_font_size_override("font_size", 64)
	_continue_prompt_label.add_theme_constant_override("outline_size", 14)
	_continue_prompt_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.95))
	_continue_prompt_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	_continue_prompt_label.z_index = 1

	_continue_prompt_layer.add_child(_continue_prompt_label)
	get_tree().current_scene.add_child(_continue_prompt_layer)


func _hide_continue_prompt() -> void:
	if _continue_prompt_layer:
		_continue_prompt_layer.queue_free()
		_continue_prompt_layer = null
		_continue_prompt_label = null

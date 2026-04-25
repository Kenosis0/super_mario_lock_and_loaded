extends Node
class_name TimerUI

signal finished
signal bonus_finished

@export var label_timer: Label

@export var time: float = 60.0  # total seconds
@export var bonus_points_per_second: int = 100

var _remaining: float
var _running := false
var _finished_emitted := false
var _bonus_active := false
var _bonus_total_points := 0
var _bonus_awarded_points := 0

var _blink_tween: Tween
var _bonus_tween: Tween
var _blink_state := 0 # 0 = none, 1 = yellow, 2 = red
var _bonus_start_time: float = 0.0
var _bonus_end_time: float = 0.0

const COLOR_NORMAL := Color(1, 1, 1, 1)
const COLOR_YELLOW := Color(1, 1, 0, 1)
const COLOR_RED := Color(1, 0, 0, 1)
const BONUS_DURATION: float = 1.0

func _ready() -> void:
	GameManager.game_timer = self
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameManager.register_game_timer(self)
	_remaining = max(time, 0.0)
	_update_label()
	_set_blink_state(_calc_blink_state())
	start()

func start() -> void:
	if _remaining <= 0.0:
		return
	_running = true
	_finished_emitted = false

func pause() -> void:
	_running = false


func start_score_bonus() -> void:
	_bonus_active = true
	_running = false
	
	if _remaining <= 0.0:
		_finish_bonus()
		return
	
	_bonus_start_time = _remaining
	_bonus_end_time = 0.0
	_bonus_total_points = int(round(_remaining * float(bonus_points_per_second)))
	_bonus_awarded_points = 0
	if _bonus_total_points <= 0:
		_finish_bonus()
		return
	
	if _bonus_tween and _bonus_tween.is_valid():
		_bonus_tween.kill()
	
	_bonus_tween = create_tween()
	_bonus_tween.set_trans(Tween.TRANS_LINEAR)
	_bonus_tween.set_ease(Tween.EASE_IN)
	_bonus_tween.tween_method(_on_bonus_tween_step, 0.0, 1.0, BONUS_DURATION)
	_bonus_tween.tween_callback(_finish_bonus)

func _on_bonus_tween_step(percent: float) -> void:
	percent = clampf(percent, 0.0, 1.0)
	_remaining = lerpf(_bonus_start_time, _bonus_end_time, percent)
	_update_label()

	var target_points := int(round(percent * float(_bonus_total_points)))
	var points_this_frame := target_points - _bonus_awarded_points
	if points_this_frame > 0:
		_bonus_awarded_points += points_this_frame
		GameManager.add_bonus_score(points_this_frame)

func reset(new_time: float = -1.0) -> void:
	if new_time >= 0.0:
		time = new_time
	_remaining = max(time, 0.0)
	_running = false
	_finished_emitted = false
	_bonus_active = false
	_bonus_total_points = 0
	_bonus_awarded_points = 0
	if _bonus_tween and _bonus_tween.is_valid():
		_bonus_tween.kill()
	_bonus_tween = null
	_update_label()
	_set_blink_state(_calc_blink_state())

func add_time(seconds: float) -> void:
	_remaining = max(_remaining + seconds, 0.0)
	_update_label()
	_set_blink_state(_calc_blink_state())

func _process(delta: float) -> void:
	if _bonus_active:
		return

	if not _running:
		return
	if _remaining <= 0.0:
		return

	_remaining = max(_remaining - delta, 0.0)
	_update_label()

	var desired := _calc_blink_state()
	if desired != _blink_state:
		_set_blink_state(desired)

	if _remaining <= 0.0:
		_running = false
		_stop_blink()
		label_timer.modulate = COLOR_NORMAL
		
		if not _finished_emitted:
			_finished_emitted = true
			emit_signal("finished")

func _calc_blink_state() -> int:
	if _remaining <= 3.0:
		return 2
	elif _remaining <= 10.0:
		return 1
	return 0

func _update_label() -> void:
	var total := int(ceil(_remaining))
	var hours := total / 3600
	var minutes := (total % 3600) / 60
	var seconds := total % 60
	label_timer.text = "%02d:%02d:%02d" % [hours, minutes, seconds]

func _set_blink_state(state: int) -> void:
	_blink_state = state
	match state:
		0:
			_stop_blink()
			label_timer.modulate = COLOR_NORMAL
		1:
			_start_blink(COLOR_YELLOW)
		2:
			_start_blink(COLOR_RED)

func _start_blink(target_color: Color) -> void:
	_stop_blink()

	label_timer.modulate = COLOR_NORMAL

	_blink_tween = create_tween()
	_blink_tween.set_loops()
	_blink_tween.set_trans(Tween.TRANS_SINE)
	_blink_tween.set_ease(Tween.EASE_IN_OUT)

	var half_period := 0.25
	_blink_tween.tween_property(label_timer, "modulate", target_color, half_period)
	_blink_tween.tween_property(label_timer, "modulate", COLOR_NORMAL, half_period)

func _stop_blink() -> void:
	if _blink_tween and _blink_tween.is_valid():
		_blink_tween.kill()
	_blink_tween = null


func _finish_bonus() -> void:
	if not _bonus_active:
		return
	
	if _bonus_awarded_points < _bonus_total_points:
		var remaining_points := _bonus_total_points - _bonus_awarded_points
		_bonus_awarded_points = _bonus_total_points
		GameManager.add_bonus_score(remaining_points)

	_bonus_active = false
	_bonus_total_points = 0
	_bonus_awarded_points = 0
	if _bonus_tween and _bonus_tween.is_valid():
		_bonus_tween.kill()
	_bonus_tween = null
	_remaining = 0.0
	_update_label()
	emit_signal("bonus_finished")


func get_remaining_time() -> float:
	return _remaining

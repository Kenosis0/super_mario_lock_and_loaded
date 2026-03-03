extends PanelContainer
class_name TimerUI

signal finished

@onready var label_timer: Label = $LabelTimer

@export var time: float = 60.0  # total seconds

var _remaining: float
var _running := false
var _finished_emitted := false

var _blink_tween: Tween
var _blink_state := 0 # 0 = none, 1 = yellow, 2 = red

const COLOR_NORMAL := Color(1, 1, 1, 1)
const COLOR_YELLOW := Color(1, 1, 0, 1)
const COLOR_RED := Color(1, 0, 0, 1)

func _ready() -> void:
	GameManager.game_timer = self
	_remaining = max(time, 0.0)
	_update_label()
	_set_blink_state(_calc_blink_state())

func start() -> void:
	if _remaining <= 0.0:
		return
	_running = true
	_finished_emitted = false

func pause() -> void:
	_running = false

func reset(new_time: float = -1.0) -> void:
	if new_time >= 0.0:
		time = new_time
	_remaining = max(time, 0.0)
	_running = false
	_finished_emitted = false
	_update_label()
	_set_blink_state(_calc_blink_state())

func add_time(seconds: float) -> void:
	_remaining = max(_remaining + seconds, 0.0)
	_update_label()
	_set_blink_state(_calc_blink_state())

func _process(delta: float) -> void:
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

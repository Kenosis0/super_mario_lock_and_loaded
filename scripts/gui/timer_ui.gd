extends Node
class_name TimerUI

signal finished
signal bonus_finished

const PARTY_POP_SCENE := preload("res://scenes/juice/party_pop.tscn")
const BONUS_POP_INTERVAL := 1
const BONUS_POP_BOTTOM_MARGIN := 0.0
const BONUS_POP_Z_INDEX := 1000

@export var label_timer: Label

@export var time: float = 60.0  # total seconds
@export var bonus_points_per_second: int = 100

var _remaining: float
var _running := false
var _finished_emitted := false
var _bonus_active := false
var _bonus_total_points := 0
var _bonus_awarded_points := 0
var _bonus_pop_elapsed := 0.0

var _blink_tween: Tween
var _bonus_tween: Tween
var _blink_state := 0 # 0 = none, 1 = yellow, 2 = red
var _bonus_start_time: float = 0.0
var _bonus_end_time: float = 0.0

const COLOR_NORMAL := Color(1, 1, 1, 1)
const COLOR_YELLOW := Color(1, 1, 0, 1)
const COLOR_RED := Color(1, 0, 0, 1)
const BONUS_DURATION_SCALE: float = 0.1
const BONUS_DURATION_MIN: float = 2.0
const BONUS_DURATION_MAX: float = 8.0

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
	_bonus_pop_elapsed = 0.0
	
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

	var bonus_duration := clampf(_bonus_start_time * BONUS_DURATION_SCALE, BONUS_DURATION_MIN, BONUS_DURATION_MAX)
	
	_bonus_tween = create_tween()
	_bonus_tween.set_trans(Tween.TRANS_LINEAR)
	_bonus_tween.set_ease(Tween.EASE_IN)
	_bonus_tween.tween_method(_on_bonus_tween_step, 0.0, 1.0, bonus_duration)
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
	_bonus_pop_elapsed = 0.0
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
	if get_tree().paused and not _bonus_active:
		return

	if _bonus_active:
		_bonus_pop_elapsed += delta
		while _bonus_pop_elapsed >= BONUS_POP_INTERVAL:
			_bonus_pop_elapsed -= BONUS_POP_INTERVAL
			_spawn_bonus_party_pops()
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
	_bonus_pop_elapsed = 0.0
	if _bonus_tween and _bonus_tween.is_valid():
		_bonus_tween.kill()
	_bonus_tween = null
	_remaining = 0.0
	_update_label()
	emit_signal("bonus_finished")


func is_bonus_active() -> bool:
	return _bonus_active


func skip_score_bonus() -> void:
	if not _bonus_active:
		return
	_finish_bonus()


func _spawn_bonus_party_pops() -> void:
	var scene_root := get_tree().current_scene
	if scene_root == null:
		return

	var world_positions := _get_bonus_spawn_world_positions()

	for i in range(3):
		var pop := PARTY_POP_SCENE.instantiate() as GPUParticles2D
		if pop == null:
			continue
		pop.process_mode = Node.PROCESS_MODE_ALWAYS
		pop.top_level = true
		pop.z_index = BONUS_POP_Z_INDEX
		scene_root.add_child(pop)
		pop.global_position = world_positions[i]
		pop.restart()
		pop.emitting = true


func _get_bonus_spawn_world_positions() -> Array[Vector2]:
	var viewport_size := get_viewport().get_visible_rect().size
	var camera := get_viewport().get_camera_2d()
	var center := Vector2.ZERO
	var zoom := Vector2.ONE

	if camera:
		center = camera.get_screen_center_position()
		zoom = camera.zoom
	else:
		center = _get_player_or_origin_position()

	var half_w := viewport_size.x * 0.5 * zoom.x
	var half_h := viewport_size.y * 0.5 * zoom.y
	var y := center.y + half_h - BONUS_POP_BOTTOM_MARGIN * zoom.y

	return [
		Vector2(center.x - half_w, y),
		Vector2(center.x, y),
		Vector2(center.x + half_w, y)
	]


func _get_player_or_origin_position() -> Vector2:
	var scene_root := get_tree().current_scene
	if scene_root == null:
		return Vector2.ZERO

	var player_node := scene_root.get_node_or_null("Player") as Node2D
	if player_node:
		return player_node.global_position

	for node in get_tree().get_nodes_in_group("player"):
		if node is Node2D:
			return (node as Node2D).global_position

	return Vector2.ZERO


func _screen_positions_to_world(screen_positions: Array[Vector2], viewport_size: Vector2) -> Array[Vector2]:
	var camera := get_viewport().get_camera_2d()
	var world_positions: Array[Vector2] = []
	for screen_pos in screen_positions:
		var world_pos := screen_pos
		if camera:
			world_pos = camera.get_screen_center_position() + (screen_pos - viewport_size * 0.5) * camera.zoom
		world_positions.append(world_pos)
	return world_positions


func get_remaining_time() -> float:
	return _remaining

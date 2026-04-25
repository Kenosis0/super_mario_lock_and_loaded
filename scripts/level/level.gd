extends Node2D
class_name LevelInterface

@export var level_data: LevelData

var level_id: int
var current_score: int
var score_objective: int
var level_started: bool


func _ready() -> void:
	if level_data:
		level_id = level_data.level_id
		current_score = level_data.current_score
		score_objective = level_data.score_objective
		level_started = level_data.level_started
		GameManager.score = current_score
		GameManager.goal_score = score_objective
		GameManager.current_level_data = level_data
	
	GameManager.level_started = true
	if not GameManager.score_changed.is_connected(_on_score_changed):
		GameManager.score_changed.connect(_on_score_changed)
	
	var hud: LevelHud = GameManager.LEVEL_HUD.instantiate()
	add_child(hud)
	var player: Player = get_node_or_null("Player") as Player
	hud.setup(level_data, player)
	
	if player and not player.died.is_connected(_on_player_died):
		player.died.connect(_on_player_died)
	
	enter_level()


func enter_level() -> void:
	pass


func exit_level() -> void:
	var new_level_data: LevelData = LevelData.new()
	new_level_data.level_id = level_id
	new_level_data.current_score = current_score
	new_level_data.score_objective = score_objective
	new_level_data.level_started = level_started
	
	level_data = new_level_data


func _on_score_changed(new_score: int, _goal: int) -> void:
	current_score = new_score
	if level_data:
		level_data.current_score = new_score

func _on_player_died() -> void:
	GameManager.finish_level(false)

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
	
	GameManager.level_started = true
	var hud: LevelHud = GameManager.LEVEL_HUD.instantiate()
	add_child(hud)
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

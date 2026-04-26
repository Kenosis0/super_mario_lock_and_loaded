extends Control
class_name LevelEndUI

const LEVEL_SELECT_UI := "res://scenes/UI/level_select.tscn"

@onready var result_label: Label = %ResultLabel
@onready var level_label: Label = %LevelLabel
@onready var score_label: Label = %ScoreLabel
@onready var objective_label: Label = %ObjectiveLabel
@onready var bonus_label: Label = %BonusLabel
@onready var max_score_label: Label = %MaxScoreLabel
@onready var percent_label: Label = %PercentLabel
@onready var grade_label: Label = %GradeLabel
@onready var retry_button: Button = %RetryButton
@onready var menu_button: Button = %MenuButton
@onready var select_level_button: Button = %SelectLevelButton
@onready var next_level_button: Button = %NextLevelButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	retry_button.pressed.connect(_on_retry_button_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)
	select_level_button.pressed.connect(_on_select_level_button_pressed)
	next_level_button.pressed.connect(_on_next_level_button_pressed)
	_refresh()


func _refresh() -> void:
	var result: LevelEndResult = GameManager.last_level_result
	if result == null:
		result = LevelEndResult.new()

	result_label.text = "YOU WIN" if result.won else "YOU LOSE"
	level_label.text = "Level %d" % result.level_id
	score_label.text = "Total Score: %d" % result.total_score
	objective_label.text = "Objective: %d" % result.score_objective
	bonus_label.text = "Time Bonus: %d / %d" % [result.time_bonus, result.max_time_bonus]
	max_score_label.text = "Max Score: %d" % result.max_score
	percent_label.text = "Completion: %.1f%%" % result.percent
	grade_label.text = "Grade: %s" % result.grade
	
	# Show/hide buttons based on result
	next_level_button.visible = result.won and GameManager.has_next_level()


func _on_retry_button_pressed() -> void:
	GameManager.restart_current_level()


func _on_menu_button_pressed() -> void:
	GameManager.return_to_main_menu()

func _on_select_level_button_pressed() -> void:
	get_tree().change_scene_to_file(LEVEL_SELECT_UI)

func _on_next_level_button_pressed() -> void:
	GameManager.next_level()

extends CanvasLayer
class_name LevelHud

@onready var time_label: Label = %TimeLabel
@onready var score_label: Label = %ScoreLabel
@onready var health_bar: ProgressBar = %HealthBar
@onready var current_level_label: Label = %CurrentLevelLabel
@onready var bronze_coin_count: Label = %BronzeCoinCount
@onready var silver_coin_count: Label = %SilverCoinCount
@onready var gold_coin_count: Label = %GoldCoinCount

var _level_data: LevelData
var _player: Player


func _ready() -> void:
	if not GameManager.score_changed.is_connected(_on_score_changed):
		GameManager.score_changed.connect(_on_score_changed)
	if not GameManager.coin_counts_changed.is_connected(_on_coin_counts_changed):
		GameManager.coin_counts_changed.connect(_on_coin_counts_changed)

	_refresh_level_label()
	_on_score_changed(GameManager.score, GameManager.goal_score)
	_on_coin_counts_changed(
		GameManager.bronze_coin_count,
		GameManager.silver_coin_count,
		GameManager.gold_coin_count
	)

	if _player:
		bind_player(_player)


func _exit_tree() -> void:
	if GameManager.score_changed.is_connected(_on_score_changed):
		GameManager.score_changed.disconnect(_on_score_changed)
	if GameManager.coin_counts_changed.is_connected(_on_coin_counts_changed):
		GameManager.coin_counts_changed.disconnect(_on_coin_counts_changed)

	if _player and _player.health_changed.is_connected(_on_player_health_changed):
		_player.health_changed.disconnect(_on_player_health_changed)


func setup(level_data: LevelData, player: Player = null) -> void:
	_level_data = level_data
	_player = player

	if is_inside_tree():
		_refresh_level_label()
		_on_score_changed(GameManager.score, GameManager.goal_score)
		_on_coin_counts_changed(
			GameManager.bronze_coin_count,
			GameManager.silver_coin_count,
			GameManager.gold_coin_count
		)
		if _player:
			bind_player(_player)


func bind_player(player: Player) -> void:
	if _player and _player.health_changed.is_connected(_on_player_health_changed):
		_player.health_changed.disconnect(_on_player_health_changed)

	_player = player
	if not _player:
		return

	if not _player.health_changed.is_connected(_on_player_health_changed):
		_player.health_changed.connect(_on_player_health_changed)

	_on_player_health_changed(_player.current_health, _player.max_health)


func _refresh_level_label() -> void:
	if _level_data:
		current_level_label.text = "Level %d" % _level_data.level_id


func _on_score_changed(new_score: int, goal_score: int) -> void:
	score_label.text = "%06d / %d" % [new_score, goal_score]


func _on_coin_counts_changed(bronze_count: int, silver_count: int, gold_count: int) -> void:
	bronze_coin_count.text = "x%d" % bronze_count
	silver_coin_count.text = "x%d" % silver_count
	gold_coin_count.text = "x%d" % gold_count


func _on_player_health_changed(current_health: int, max_health: int) -> void:
	health_bar.max_value = float(max_health)
	health_bar.value = float(current_health)

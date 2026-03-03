extends Node2D
class_name ScorePop

@onready var label: Label = $Label

var score: int

func _ready() -> void:
	label.text = str(score)
	$AnimationPlayer.play("spawn")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()

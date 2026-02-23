extends Node

var score: int = 0

func add_score(label: Label, amount: int) -> void:
	score += amount
	label.text = "%06d" % score

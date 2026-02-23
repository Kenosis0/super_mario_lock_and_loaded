extends Node2D

@onready var body: Sprite2D = $Body
@onready var foot_l: Sprite2D = $FootL
@onready var foot_r: Sprite2D = $FootR
@onready var head: Sprite2D = $Head

func _ready() -> void:
	if body.material:
		body.material = body.material.duplicate()
	if foot_l.material:
		foot_l.material = foot_l.material.duplicate()
	if foot_r.material:
		foot_r.material = foot_r.material.duplicate()
	if head.material:
		head.material = head.material.duplicate()

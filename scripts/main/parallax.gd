extends Node2D
@onready var cloud_animations: AnimationPlayer = $CloudAnimations

@onready var clouds: Sprite2D = $Cloud1/Clouds
@onready var clouds_2: Sprite2D = $Cloud1/Clouds2
@onready var clouds_3: Sprite2D = $Cloud2/Clouds2
@onready var clouds_4: Sprite2D = $Cloud2/Clouds3
@onready var clouds_5: Sprite2D = $Cloud3/Clouds3
@onready var clouds_6: Sprite2D = $Cloud3/Clouds5
@onready var clouds_7: Sprite2D = $Cloud3/Clouds4

@onready var cloud_1: Parallax2D = $Cloud1
@onready var cloud_2: Parallax2D = $Cloud2
@onready var cloud_3: Parallax2D = $Cloud3

func _ready() -> void:
	start_loop()


#func _process(delta: float) -> void:


func start_loop():
	var tween = create_tween()
	tween.tween_property(clouds, "scale", Vector2(randf_range(0.8, 1.2), randf_range(0.8, 1.2)), 1)
	var clouds_2_tween = create_tween()
	clouds_2_tween.tween_property(clouds_2, "scale", Vector2(randf_range(0.8, 1.2), randf_range(0.8, 1.2)), 1)
	var clouds_3_tween = create_tween()
	clouds_3_tween.tween_property(clouds_3, "scale", Vector2(randf_range(0.8, 1.2), randf_range(0.8, 1.2)), 1)
	var clouds_4_tween = create_tween()
	clouds_4_tween.tween_property(clouds_4, "scale", Vector2(randf_range(0.8, 1.2), randf_range(0.8, 1.2)), 1)
	var clouds_5_tween = create_tween()
	clouds_5_tween.tween_property(clouds_5, "scale", Vector2(randf_range(0.8, 1.2), randf_range(0.8, 1.2)), 1)
	var clouds_6_tween = create_tween()
	clouds_6_tween.tween_property(clouds_6, "scale", Vector2(randf_range(0.8, 1.2), randf_range(0.8, 1.2)), 1)
	var clouds_7_tween = create_tween()
	clouds_7_tween.tween_property(clouds_7, "scale", Vector2(randf_range(0.8, 1.2), randf_range(0.8, 1.2)), 1)
	tween.finished.connect(start_loop)

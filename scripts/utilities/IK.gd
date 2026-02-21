@tool
extends Node2D

@export_tool_button("Reset Rest Pos") var rest_rest_pos = _reset_rest_pos
@export_tool_button("Overwrite Rest Pos") var  set_rest_pos = _set_rest_pos


var rest_pos: Vector2


func _set_rest_pos() -> void:
	print("New rest position: ", rest_pos)
	rest_pos = global_position


func _reset_rest_pos() -> void:
	global_position = rest_pos

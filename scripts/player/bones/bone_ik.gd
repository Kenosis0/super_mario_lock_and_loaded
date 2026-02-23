@tool
extends Node2D

@export_tool_button("Reset IK Pos") var reset_ik_pos = _reset_ik_pos
@export_tool_button("Reset IK Rotation") var reset_ik_rot = _reset_ik_rot
@export_tool_button("Reset IK Scale") var reset_ik_sc = _reset_ik_sc

@export_category("Marker")
@export_node_path("Marker2D") var head_look_at
@export_node_path("Marker2D") var arm_RIK
@export_node_path("Marker2D") var arm_LIK
@export_node_path("Marker2D") var leg_RIK
@export_node_path("Marker2D") var leg_LIK
@export_category("Bone")
@export_node_path("Bone2D") var b_head_look_at
@export_node_path("Bone2D") var b_arm_RIK
@export_node_path("Bone2D") var b_arm_LIK
@export_node_path("Bone2D") var b_leg_RIK
@export_node_path("Bone2D") var b_leg_LIK

@onready var node_head_look_at = get_node(head_look_at)
@onready var node_arm_RIK = get_node(arm_RIK)
@onready var node_arm_LIK = get_node(arm_LIK)
@onready var node_leg_RIK = get_node(leg_RIK)
@onready var node_leg_LIK = get_node(leg_LIK)
@onready var node_b_head_look_at = get_node(b_head_look_at)
@onready var node_b_arm_RIK = get_node(b_arm_RIK)
@onready var node_b_arm_LIK = get_node(b_arm_LIK)
@onready var node_b_leg_RIK = get_node(b_leg_RIK)
@onready var node_b_leg_LIK = get_node(b_leg_LIK)

func _reset_ik_pos() -> void:
	if node_head_look_at and node_head_look_at:
		node_head_look_at.global_position = node_b_head_look_at.global_position
		node_head_look_at.global_position.x += 500
	if node_arm_RIK and node_arm_RIK:
		node_arm_RIK.global_position = node_b_arm_RIK.global_position
	if node_arm_LIK and node_arm_LIK:
		node_arm_LIK.global_position = node_b_arm_LIK.global_position
	if node_leg_RIK and node_leg_RIK:
		node_leg_RIK.global_position = node_b_leg_RIK.global_position
	if node_leg_LIK and node_leg_LIK:
		node_leg_LIK.global_position = node_b_leg_LIK.global_position


func _reset_ik_rot() -> void:
	if node_arm_RIK and node_arm_RIK:
		node_arm_RIK.rotation = 0.0
	if node_arm_LIK and node_arm_LIK:
		node_arm_LIK.rotation = 0.0
	if node_leg_RIK and node_leg_RIK:
		node_leg_RIK.rotation = 0.0
	if node_leg_LIK and node_leg_LIK:
		node_leg_LIK.rotation = 0.0


func _reset_ik_sc() -> void:
	if node_head_look_at and node_head_look_at:
		node_head_look_at.scale = node_b_head_look_at.scale
	if node_arm_RIK and node_arm_RIK:
		node_arm_RIK.scale = node_b_arm_RIK.scale
	if node_arm_LIK and node_arm_LIK:
		node_arm_LIK.scale = node_b_arm_LIK.scale
	if node_leg_RIK and node_leg_RIK:
		node_leg_RIK.scale = node_b_leg_RIK.scale
	if node_leg_LIK and node_leg_LIK:
		node_leg_LIK.scale = node_b_leg_LIK.scale

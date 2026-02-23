extends Node
class_name LimbControlComponent
@onready var anim: AnimationPlayer = $"../AnimationPlayer"



func _ready() -> void:
	return
	enable_look_at_cursor(false)


func enable_look_at_cursor(value: bool) -> void:
	set_node_property_track_enable("RESET", "head", "position", value)
	set_node_property_track_enable("RESET", "head", "rotation", value)
	set_node_property_track_enable("RESET", "uparmr", "position", value)
	set_node_property_track_enable("RESET", "uparmr", "rotation", value)
	set_node_property_track_enable("RESET", "loarmr", "position", value)
	set_node_property_track_enable("RESET", "loarmr", "rotation", value)
	set_node_property_track_enable("RESET", "handr", "position", value)
	set_node_property_track_enable("RESET", "handr", "rotation", value)
	set_node_property_track_enable("RESET", "uparml", "position", value)
	set_node_property_track_enable("RESET", "uparml", "rotation", value)
	set_node_property_track_enable("RESET", "loarml", "position", value)
	set_node_property_track_enable("RESET", "loarml", "rotation", value)
	set_node_property_track_enable("RESET", "handl", "position", value)
	set_node_property_track_enable("RESET", "handl", "rotation", value)
	
	set_node_property_track_enable("MarioShooter/idle", "head", "position", value)
	set_node_property_track_enable("MarioShooter/idle", "head", "rotation", value)
	set_node_property_track_enable("MarioShooter/idle", "uparmr", "position", value)
	set_node_property_track_enable("MarioShooter/idle", "uparmr", "rotation", value)
	set_node_property_track_enable("MarioShooter/idle", "loarmr", "position", value)
	set_node_property_track_enable("MarioShooter/idle", "loarmr", "rotation", value)
	set_node_property_track_enable("MarioShooter/idle", "handr", "position", value)
	set_node_property_track_enable("MarioShooter/idle", "handr", "rotation", value)
	set_node_property_track_enable("MarioShooter/idle", "uparml", "position", value)
	set_node_property_track_enable("MarioShooter/idle", "uparml", "rotation", value)
	set_node_property_track_enable("MarioShooter/idle", "loarml", "position", value)
	set_node_property_track_enable("MarioShooter/idle", "loarml", "rotation", value)
	set_node_property_track_enable("MarioShooter/idle", "handl", "position", value)
	set_node_property_track_enable("MarioShooter/idle", "handl", "rotation", value)
	
	set_node_property_track_enable("MarioShooter/run", "head", "position", value)
	set_node_property_track_enable("MarioShooter/run", "head", "rotation", value)
	set_node_property_track_enable("MarioShooter/run", "uparmr", "position", value)
	set_node_property_track_enable("MarioShooter/run", "uparmr", "rotation", value)
	set_node_property_track_enable("MarioShooter/run", "loarmr", "position", value)
	set_node_property_track_enable("MarioShooter/run", "loarmr", "rotation", value)
	set_node_property_track_enable("MarioShooter/run", "handr", "position", value)
	set_node_property_track_enable("MarioShooter/run", "handr", "rotation", value)
	set_node_property_track_enable("MarioShooter/run", "uparml", "position", value)
	set_node_property_track_enable("MarioShooter/run", "uparml", "rotation", value)
	set_node_property_track_enable("MarioShooter/run", "loarml", "position", value)
	set_node_property_track_enable("MarioShooter/run", "loarml", "rotation", value)
	set_node_property_track_enable("MarioShooter/run", "handl", "position", value)
	set_node_property_track_enable("MarioShooter/run", "handl", "rotation", value)
	
	set_node_property_track_enable("MarioShooter/walk", "head", "position", value)
	set_node_property_track_enable("MarioShooter/walk", "head", "rotation", value)
	set_node_property_track_enable("MarioShooter/walk", "uparmr", "position", value)
	set_node_property_track_enable("MarioShooter/walk", "uparmr", "rotation", value)
	set_node_property_track_enable("MarioShooter/walk", "loarmr", "position", value)
	set_node_property_track_enable("MarioShooter/walk", "loarmr", "rotation", value)
	set_node_property_track_enable("MarioShooter/walk", "handr", "position", value)
	set_node_property_track_enable("MarioShooter/walk", "handr", "rotation", value)
	set_node_property_track_enable("MarioShooter/walk", "uparml", "position", value)
	set_node_property_track_enable("MarioShooter/walk", "uparml", "rotation", value)
	set_node_property_track_enable("MarioShooter/walk", "loarml", "position", value)
	set_node_property_track_enable("MarioShooter/walk", "loarml", "rotation", value)
	set_node_property_track_enable("MarioShooter/walk", "handl", "position", value)
	set_node_property_track_enable("MarioShooter/walk", "handl", "rotation", value)
	
	set_node_property_track_enable("MarioShooter/jump", "head", "position", value)
	set_node_property_track_enable("MarioShooter/jump", "head", "rotation", value)
	set_node_property_track_enable("MarioShooter/jump", "uparmr", "position", value)
	set_node_property_track_enable("MarioShooter/jump", "uparmr", "rotation", value)
	set_node_property_track_enable("MarioShooter/jump", "loarmr", "position", value)
	set_node_property_track_enable("MarioShooter/jump", "loarmr", "rotation", value)
	set_node_property_track_enable("MarioShooter/jump", "handr", "position", value)
	set_node_property_track_enable("MarioShooter/jump", "handr", "rotation", value)
	set_node_property_track_enable("MarioShooter/jump", "uparml", "position", value)
	set_node_property_track_enable("MarioShooter/jump", "uparml", "rotation", value)
	set_node_property_track_enable("MarioShooter/jump", "loarml", "position", value)
	set_node_property_track_enable("MarioShooter/jump", "loarml", "rotation", value)
	set_node_property_track_enable("MarioShooter/jump", "handl", "position", value)
	set_node_property_track_enable("MarioShooter/jump", "handl", "rotation", value)


func set_node_property_track_enable(animation_name: StringName, node: StringName, property: StringName, enable: bool) -> void:
	var animation: Animation = anim.get_animation(animation_name)
	#print("at animation: ", animation_name)
	if animation == null:
		return
	
	for idx in animation.get_track_count():
		var node_path: StringName = animation.track_get_path(idx).get_concatenated_names().to_lower()
		var node_property: StringName = animation.track_get_path(idx).get_concatenated_subnames().to_lower()
		
		if node_path.ends_with(node.to_lower()) and node_property.ends_with(property.to_lower()):
			animation.track_set_enabled(idx, enable)
			
			#print("found track: ", node, ":", property, " at index: ", idx)
			
		

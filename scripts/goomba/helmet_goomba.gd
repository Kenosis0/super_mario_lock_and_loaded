extends Goomba
class_name HelmetGoomba

@onready var head: Sprite2D = $Goomba/Sprites/Head
@onready var hat: Sprite2D = %Helmet

var _helmet_dropped := false


func enter_goomba() -> void:
	if not damaged.is_connected(_on_damaged):
		damaged.connect(_on_damaged)


func update(delta: float) -> void:
	if _helmet_dropped:
		return
	hat.scale = head.scale
	hat.rotation = head.rotation


func _on_damaged() -> void:
	if _helmet_dropped:
		return

	_helmet_dropped = true

	var rigid_helmet := RigidBody2D.new()
	rigid_helmet.name = "%s_Helmet" % name
	rigid_helmet.global_transform = hat.global_transform
	rigid_helmet.scale = Vector2.ONE
	rigid_helmet.collision_layer = 0
	rigid_helmet.collision_mask = 0

	get_tree().current_scene.add_child(rigid_helmet)
	hat.reparent(rigid_helmet, true)
	rigid_helmet.apply_impulse(Vector2(randf_range(-110.0, 110.0), -260.0))
	rigid_helmet.angular_velocity = randf_range(-5.0, 5.0)

	var cleanup_timer := Timer.new()
	cleanup_timer.one_shot = true
	cleanup_timer.wait_time = 5.0
	rigid_helmet.add_child(cleanup_timer)
	cleanup_timer.timeout.connect(rigid_helmet.queue_free)
	cleanup_timer.start()

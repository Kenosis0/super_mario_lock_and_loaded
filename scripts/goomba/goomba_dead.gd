extends RigidBody2D
@onready var lifetime: Timer = $Lifetime

@export var jump_force: float = 400.0

func _ready():
	# Wait one physics frame to ensure body is active
	await get_tree().physics_frame
	apply_impulse(Vector2.UP * jump_force)

	lifetime.start(5)


func _on_lifetime_timeout() -> void:
	queue_free()

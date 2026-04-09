extends StateInterface
class_name GoombaStateInterface

var goomba: Goomba

func _init(g: Goomba) -> void:
	goomba = g


func enter(prev_state: String) -> void:
	pass


func exit() -> void:
	# Called when the state is exited
	pass

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	# Called every physics frame update
	pass

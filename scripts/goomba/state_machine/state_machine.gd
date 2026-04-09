extends StateMachine
class_name GoombaFSM


func set_owner_goomba(g: Goomba) -> void:
	owner = g
	for s in states:
		print(s)

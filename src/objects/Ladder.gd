extends Area2D

func _on_body_entered(body):
	if (body.name == "Player"):
		body.setLadder(global_position.x)

func _on_body_exited(body):
	if (body.name == "Player"):
		body.unsetLadder()

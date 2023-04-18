extends Area2D
class_name AttackLibrary

var lastAttack :CollisionShape2D = null

func setAttack(idx:int):
	unsetAttack()
	if (get_child_count() <= idx): return
	lastAttack = get_child(idx)
	lastAttack.setup()

func unsetAttack():
	if (lastAttack != null):
		lastAttack.unset()
		lastAttack = null

func _on_body_entered(body):
	if (lastAttack != null):
		lastAttack.apply(body)

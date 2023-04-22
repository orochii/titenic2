extends Area2D
class_name AttackLibrary

var lastAttack :CollisionShape2D = null

func playFx(idx:int):
	if (get_child_count() <= idx): return
	var c = get_child(idx)
	c.playFx()

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
	if body==get_parent(): return
	if (lastAttack != null):
		lastAttack.apply(body)

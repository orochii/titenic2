extends Area2D

const INTERACT_DELAY:float = 0.2
const COLLECT_DELAY:float = 0.5

@export var recovery:int = 2

var queuedInteraction = null
var timer:float = 0
var collected:bool = false

func _process(delta):
	timer += delta
	if collected:
		position.y -= 1
		if (timer > COLLECT_DELAY):
			queue_free()

func collect():
	State.player.damage(recovery,Damageable.DamageType.BOMB)
	collected = true
	timer = 0

func _on_body_entered(body):
	if (timer < INTERACT_DELAY):
		return
	if body.name=="Player":
		collect()

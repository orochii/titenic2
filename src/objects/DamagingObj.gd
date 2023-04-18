extends Area2D

@export var value:int
@export var kind:Damageable.DamageType

func _on_body_entered(body):
	if (body.has_method("isDamageable")):
		body.damage(value,kind)

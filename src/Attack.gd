extends CollisionShape2D
class_name Attack

@export var value:int
@export var kind:Damageable.DamageType

func _ready():
	unset()

func setup():
	visible = true
	disabled = false

func unset():
	visible = false
	disabled = true

func apply(body: Node2D):
	if (body.has_method("isDamageable")):
		body.damage(value,kind)

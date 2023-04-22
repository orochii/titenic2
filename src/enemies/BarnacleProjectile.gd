extends Node2D

@export var life=1
@export var speed:Vector2=Vector2(0,-60)
@export var dmg=1
@export var type:Damageable.DamageType = Damageable.DamageType.ENEMY
@export var cast:RayCast2D = null

func _process(delta):
	# Move forward
	var move = speed*delta
	var mt = global_transform.basis_xform(move)
	global_position += mt
	# Check for collision
	if cast.is_colliding():
		var c = cast.get_collider()
		if c.has_method("isDamageable"):
			c.damage(dmg,type)
		queue_free()
		return
	# Advance life
	life -= delta
	if life < 0:
		queue_free()

func ignore(n):
	cast.add_exception(n)

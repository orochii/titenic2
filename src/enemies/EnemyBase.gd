class_name EnemyBase
extends CharacterBody2D

signal death(pos:Vector2)

@export var max_Lifes = 2
@export var anim:AnimatedSprite2D
@export var onDeathFX: PackedScene
var currDmg = 0
var invincTimer = 0.0
# Timing stuff
func updateInvincTime(delta):
	invincTimer -= delta
	if (invincTimer <= 0):
		#anim.visible = true
		anim.modulate = Color.WHITE
	else:
		var f = int(invincTimer * 10)
		anim.modulate = Color.RED if f%2==0 else Color.WHITE

# ==============================================================================
# DAMAGEABLE "INTERFACE" (duck-typing sucks)
# ==============================================================================
func remLifes():
	return maxLifes() - currDmg
func maxLifes():
	return max_Lifes
func isDamageable():
	return true
func damage(value:int,kind:Damageable.DamageType):
	if (invincTimer > 0):
		return
	if (kind != Damageable.DamageType.ENEMY):
		invincTimer = 0.2
		currDmg = min((currDmg + value),maxLifes())
		if currDmg == maxLifes():
			die()
func die():
	death.emit(global_position + Vector2(0,-8))
	if onDeathFX != null:
		var fx = onDeathFX.instantiate() as Node2D
		get_parent().add_child(fx)
		fx.global_position = global_position
	self.queue_free()

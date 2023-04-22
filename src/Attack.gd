extends CollisionShape2D
class_name Attack

@export var value:int
@export var kind:Damageable.DamageType
@export var sfxAttack: AudioStreamPlayer2D = null
@export var sfxDamage: AudioStreamPlayer2D = null

func _ready():
	unset()

func playFx():
	if sfxAttack != null: sfxAttack.play()

func setup():
	visible = true
	disabled = false

func unset():
	visible = false
	disabled = true

func apply(body: Node2D):
	if (body.has_method("isDamageable")):
		if sfxDamage != null: sfxDamage.play()
		body.damage(value,kind)

class_name BreakableWall
extends ReactObject

@export var collider : CollisionShape2D
@export var flagIdx = 0

func breakWall():
	collider.disabled = true
	collider.visible = false

func refresh():
	if State.getFlag(flagIdx) != 0:
		breakWall()

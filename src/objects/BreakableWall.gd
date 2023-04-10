class_name BreakableWall
extends ReactObject

@export var collider : CollisionShape2D
@export var flagIdx = 0
@export var flagValue = 1

func disable():
	collider.disabled = true
	collider.visible = false

func refresh():
	if isSet():
		disable()

func setFlag():
	var v = State.getFlag(flagIdx)
	v = v | flagValue
	State.setFlag(flagIdx, v)

func isSet():
	var v = State.getFlag(flagIdx)
	v = v & flagValue
	return v != 0

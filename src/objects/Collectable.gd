extends ReactObject

@export var collider : CollisionShape2D
@export var flagIdx = 0
@export var flagValue = 1

func disable():
	collider.disabled = true
	collider.visible = false

func refresh():
	if State.getFlag(flagIdx) != 0:
		disable()

func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if (body.name == "Player"):
		var v = State.getFlag(flagIdx)
		v = v | flagValue
		State.setFlag(flagIdx, v)
		disable()

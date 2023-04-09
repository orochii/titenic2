extends ReactObject

@export var collider : CollisionShape2D
@export var flagIdx = 0
@export var flagValue = 1
@export_multiline var popupText = ""

func disable():
	collider.disabled = true
	collider.visible = false

func refresh():
	if isSet():
		disable()

func isSet():
	var v = State.getFlag(flagIdx)
	v = v & flagValue
	return v != 0

func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if isSet():
		return
	if (body.name == "Player"):
		var v = State.getFlag(flagIdx)
		v = v | flagValue
		State.setFlag(flagIdx, v)
		disable()
		var popup = Global.popUp().showPopup(popupText)

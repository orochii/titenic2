extends ReactObject

@export var collider : CollisionShape2D
@export var flagIdx = 0
@export var flagValue = 1
@export var varIdx= -1
@export var varSum= 0
@export_multiline var popupText = ""

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

func sumFlag():
	if varIdx >= 0:
		var v = State.getFlag(varIdx)
		v = v + varSum
		State.setFlag(varIdx, v)
		State.player.refresh()

func isSet():
	var v = State.getFlag(flagIdx)
	v = v & flagValue
	return v != 0

func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if isSet():
		return
	if (body.name == "Player"):
		setFlag()
		sumFlag()
		disable()
		var popup = Global.popUp().showPopup(popupText)

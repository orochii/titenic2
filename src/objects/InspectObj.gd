extends Area2D

@export var icon:Sprite2D
@export var waitForInput:bool = true
@export_multiline var popupText:Array[String] = [""]
@export var triggerOnEnd:Node2D = null

var inRange=false
var idx=0

var timer:float = 0

func _process(delta):
	if timer != 0:
		if inRange && Input.is_action_just_pressed("ui_cancel"):
			interact()
	timer += delta

func interact():
	idx = 0
	Global.msgBox().connect("onClose", nextText)
	if icon != null: icon.visible = false
	nextText()
func nextText():
	timer=0
	if idx < popupText.size():
		Global.msgBox().showPopup(popupText[idx],0.2)
		idx += 1
	else:
		Global.msgBox().disconnect("onClose",nextText)
		if icon != null: icon.visible = inRange
		# Might want to trigger something on end?
		trigger(triggerOnEnd)

func trigger(t):
	if t != null && t.has_method("interact"):
		t.interact()

func _on_body_entered(body):
	if body.name=="Player":
		if waitForInput:
			inRange = true
			if icon != null: icon.visible = true
		else:
			interact()

func _on_body_exited(body):
	if body.name=="Player":
		inRange = false
		if icon != null: icon.visible = false

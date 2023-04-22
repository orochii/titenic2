extends Area2D

@export var targetAreaPath: NodePath
@export var triggerObj: Node2D = null

@onready var targetArea = get_node(targetAreaPath)

var triggered = false

func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if (body.name == "Player"):
		State.changeArea(targetArea)
		trigger(triggerObj)

func trigger(t):
	if triggered: return
	triggered = true
	if t != null && t.has_method("interact"):
		t.interact()

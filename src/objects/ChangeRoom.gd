extends Area2D

@export var targetAreaPath: NodePath
@onready var targetArea = get_node(targetAreaPath)

func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if (body.name == "Player"):
		State.changeArea(targetArea)

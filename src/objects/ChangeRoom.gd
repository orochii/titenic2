extends Area2D

@export var targetAreaPath: NodePath
@onready var targetArea = get_node(targetAreaPath)

func change_area():
	var cam = get_viewport().get_camera_2d()
	if (cam != null):
		if targetArea.has_meta("areaSize"):
			var r: Vector2i = targetArea.get_meta("areaSize")
			cam.limit_left = targetArea.position.x
			cam.limit_top = targetArea.position.y
			cam.limit_right = targetArea.position.x + r.x
			cam.limit_bottom = targetArea.position.y + r.y

func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if (body.name == "Player"):
		change_area()

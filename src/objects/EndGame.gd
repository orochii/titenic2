extends Node2D

@export_file("*.tscn") var title:String

func interact():
	get_tree().change_scene_to_file(title)

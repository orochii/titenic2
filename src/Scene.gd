extends Node2D

@export var tint : AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	tint.play("fade_in")
	State.initialize()
	Global.presearch()

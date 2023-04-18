extends Node2D

@export var tint : AnimationPlayer

@export var mainUI:HUD

# Called when the node enters the scene tree for the first time.
func _ready():
	tint.play("fade_in")
	State.initialize()
	Global.presearch()
	var p = $Player
	State.player = p
	p.hudRef = mainUI
	mainUI.refresh()

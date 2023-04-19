extends Node2D

@export_category("UI")
@export var tint : AnimationPlayer
@export var mainUI:HUD
@export var death:GameOver

# Called when the node enters the scene tree for the first time.
func _ready():
	tint.play("fade_in")
	State.initialize()
	Global.presearch()
	var p = $Player
	p.connect("death", onDeath)
	State.player = p
	p.hudRef = mainUI
	mainUI.refresh()

func onDeath():
	death.showScreen()

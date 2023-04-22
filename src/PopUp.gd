extends Control
class_name PopUp

signal onClose

@export var shownText : BitmapText
@export var cooldown = 1.0

var _timer = 0.0

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _process(delta):
	if !visible: return
	_timer -= delta
	if (_timer < 0):
		if Input.is_action_just_pressed("ui_select") || Input.is_action_just_pressed("ui_cancel"):
			visible = false
			get_tree().paused = false
			onClose.emit()

func showPopup(text:String,delay=cooldown):
	shownText.text = text
	_timer = delay
	visible = true
	get_tree().paused = true

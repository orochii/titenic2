extends Control
class_name PopUp

@export var shownText : BitmapText
@export var cooldown = 1.0

var _timer = 0.0

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _process(delta):
	_timer += delta
	if (_timer > cooldown):
		if (Input.is_action_just_pressed("ui_select")):
			visible = false
			get_tree().paused = false

func showPopup(text:String):
	shownText.text = text
	_timer = 0
	visible = true
	get_tree().paused = true

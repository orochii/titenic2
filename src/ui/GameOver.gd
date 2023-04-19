extends Control
class_name GameOver

const MAX_OPTIONS:int = 2

@export_category("UI Elements")
@export var passText:BitmapText
@export var cursor:BitmapText
@export_category("Scenes")
@export_file("*.tscn") var title:String

var cursorOrigPos:Vector2
var index:int = 0
var repeatTimer:float = 0

func _ready():
	cursorOrigPos = cursor.position

func _process(delta):
	if visible:
		# Cursor input
		var d = roundi(Input.get_axis("ui_up","ui_down"))
		if d:
			if repeatTimer > 0:
				repeatTimer -= delta
			else:
				repeatTimer = 0.2
				index = (index + d + MAX_OPTIONS) % MAX_OPTIONS
				# Reposition cursor
				cursor.position = cursorOrigPos + Vector2(0,index*8)
		else:
			repeatTimer = 0
		# Selection
		if Input.is_action_just_pressed("ui_select"):
			match(index):
				0: #Retry
					get_tree().reload_current_scene()
				1: #To Title
					get_tree().change_scene_to_file(title)

func showScreen():
	var pw:String = State.generatePassword()
	pw = pw.insert(4," ")
	passText.text = pw
	visible = true

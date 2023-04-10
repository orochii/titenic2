extends Node2D

enum MenuState { IDLE, MAIN, PASS }

var MAX_PASS_COLUMNS = 8
var MAX_PASS_OPTIONS = 16
var REPEAT_DELAY = 0.1

@export var animator : AnimationPlayer
@export var next_scene : PackedScene
@export var cursor : MeshInstance2D
@export var passCursor : MeshInstance2D
@export var passMarker : MeshInstance2D
@export var passString : BitmapText

var cursorStart = Vector2(0,0)
var passcursorStart = Vector2(0,0)
var passMarkerStart = Vector2(0,0)
var state = MenuState.IDLE
var idx = 0
var timer = 0
# Password stuff
var _currPassword = ""

func _ready():
	cursorStart = cursor.position
	passcursorStart = passCursor.position
	passMarkerStart = passMarker.position
	animator.play("title_screen")

func _on_title_animations_animation_finished(anim_name):
	match anim_name:
		"title_screen":
			cursor.visible = true
			state = MenuState.MAIN
			idx = 0
		"return_screen":
			cursor.visible = true
			state = MenuState.MAIN
			idx = 1
		"pass_screen":
			state = MenuState.PASS
			idx = 0
			passCursor.position = passcursorStart
			_currPassword = ""
			updatePassVisuals()
		"next_screen":
			gotoNext()

func _process(delta):
	if timer > 0:
		timer -= delta
	match state:
		MenuState.IDLE:
			return
		MenuState.MAIN:
			if (Input.is_action_pressed("ui_up")):
				idx = 0
			elif (Input.is_action_pressed("ui_down")):
				idx = 1
			cursor.position = cursorStart + Vector2(0, 16 * idx)
			if (Input.is_action_just_pressed("ui_select")):
				state = MenuState.IDLE
				cursor.visible = false
				match idx:
					0:
						animator.play("next_screen")
					1:
						animator.play("pass_screen")
		MenuState.PASS:
			# Movement
			if timer <= 0:
				if (Input.is_action_pressed("ui_up")):
					idx = (idx+MAX_PASS_OPTIONS-MAX_PASS_COLUMNS) % MAX_PASS_OPTIONS
					timer = REPEAT_DELAY
				elif (Input.is_action_pressed("ui_down")):
					idx = (idx+MAX_PASS_COLUMNS) % MAX_PASS_OPTIONS
					timer = REPEAT_DELAY
				elif (Input.is_action_pressed("ui_left")):
					idx = (idx+MAX_PASS_OPTIONS-1) % MAX_PASS_OPTIONS
					timer = REPEAT_DELAY
				elif (Input.is_action_pressed("ui_right")):
					idx = (idx+1) % MAX_PASS_OPTIONS
					timer = REPEAT_DELAY
			# Reposition cursor
			var _x = idx % MAX_PASS_COLUMNS * 16
			var _y = idx / MAX_PASS_COLUMNS * 16
			passCursor.position = passcursorStart + Vector2(_x, _y)
			# Cancel
			if (Input.is_action_just_pressed("ui_cancel")):
				if _currPassword.length() == 0:
					state = MenuState.IDLE
					animator.play("return_screen")
				else:
					passDeleteChar()
			# Accept
			elif (Input.is_action_just_pressed("ui_select")):
				if _currPassword.length() == State.composition.size():
					State.password = _currPassword
					animator.play("next_screen")
				else:
					passWriteChar(idx)

func gotoNext():
	get_tree().change_scene_to_file(next_scene.resource_path)

# Password stuff
func passWriteChar(cIdx):
	# Do stuff
	if _currPassword.length() < State.composition.size():
		var c = String.chr(cIdx + 65)
		_currPassword += c
	# Update
	updatePassVisuals()

func passDeleteChar():
	#Do stuff
	if _currPassword.length() > 0:
		_currPassword = _currPassword.substr(0, _currPassword.length()-1)
	# Update
	updatePassVisuals()

func updatePassVisuals():
	var _t = ""
	for i in range(0, State.composition.size()):
		_t += _currPassword.substr(i,1)
		if i==3:
			_t += " "
	passString.text = _t
	var mxD = (_currPassword.length()*8)
	if _currPassword.length()>3:
		mxD += 8
	passMarker.position = passMarkerStart + Vector2(mxD, 0)

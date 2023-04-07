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

var cursorStart = Vector2(0,0)
var passcursorStart = Vector2(0,0)
var passMarkerStart = Vector2(0,0)
var state = MenuState.IDLE
var idx = 0
var timer = 0

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
				state = MenuState.IDLE
				animator.play("return_screen")
			# Accept
			elif (Input.is_action_just_pressed("ui_select")):
				animator.play("next_screen")

func gotoNext():
	get_tree().change_scene_to_file(next_scene.resource_path)

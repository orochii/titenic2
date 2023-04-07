extends CharacterBody2D

enum MoveState {IDLE, RUN, RAISING, FALLING, CROUCHING}
enum ActionState {IDLE, SLIDE, ATTACK}

@export var anim: AnimatedSprite2D
@export var standCollision: CollisionShape2D

const SPEED = 150.0
const JUMP_VELOCITY = -270.0
const JUMP_TIME = 0.10
const MAX_Y_VELOCITY = 400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumping = false
var jumpTime= 0
var moveState= MoveState.IDLE
var actionState = ActionState.IDLE
var actionTimer = 0
var remJumps=0

func _physics_process(delta):
	# Acting update
	if actionState != ActionState.IDLE:
		actionTimer -= delta
		if actionTimer <= 0:
			actionState = ActionState.IDLE
	# Testing
	if Input.is_action_just_pressed("ui_cancel"):
		print(State.generatePassword())
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y > 0:
			velocity.y += gravity * delta
		velocity.y = clampf(velocity.y, -MAX_Y_VELOCITY, MAX_Y_VELOCITY)
	else:
		remJumps = maxJumps()
	# Read direction.
	var direction = Input.get_axis("ui_left", "ui_right")
	# Handle Jump.
	if Input.is_action_just_pressed("ui_select") and can_jump():
		if Input.is_action_pressed("ui_down"):
			if direction:
				action_slide(direction)
			else:
				position.y += 2
		else:
			velocity.y = JUMP_VELOCITY
			jumpTime = JUMP_TIME
			jumping = true
			remJumps -= 1
	elif jumping:
		if velocity.y < 0 and Input.is_action_pressed("ui_select"):
			velocity.y = JUMP_VELOCITY
		else:
			jumping = false
		if jumpTime > 0:
			jumpTime -= delta
		else:
			jumping = false
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if direction and not acting():
		moveState = MoveState.RUN
		standCollision.disabled = false
		anim.flip_h = direction < 0
		velocity.x = direction * SPEED
		if (direction < 0):
			anim.offset.x = 2
		else:
			anim.offset.x = -2
	else:
		if not acting():
			moveState = MoveState.IDLE
			standCollision.disabled = false
			velocity.x = move_toward(velocity.x, 0, SPEED)
		else:
			update_action()
	if not is_on_floor():
		if velocity.y < 0:
			moveState = MoveState.RAISING
		elif velocity.y > 0:
			moveState = MoveState.FALLING
	elif Input.is_action_pressed("ui_down") and not acting():
		moveState = MoveState.CROUCHING
		standCollision.disabled = true
		velocity.x = 0
	updateAnimation()
	move_and_slide()

func updateAnimation():
	match actionState:
		ActionState.ATTACK:
			match moveState:
				MoveState.IDLE:
					anim.play("attackIdle")
				MoveState.RUN:
					anim.play("attackRun")
				MoveState.RAISING:
					anim.play("attackAirUp")
				MoveState.FALLING:
					anim.play("attackAirDown")
				MoveState.CROUCHING:
					anim.play("attackCrouch")
		ActionState.SLIDE:
			anim.play("slide")
		ActionState.IDLE:
			match moveState:
				MoveState.IDLE:
					anim.play("idle")
				MoveState.RUN:
					anim.play("run")
				MoveState.RAISING:
					anim.play("airUp")
				MoveState.FALLING:
					anim.play("airDown")
				MoveState.CROUCHING:
					anim.play("crouch")

func action_slide(direction):
	if !hasBoots():
		return
	actionState = ActionState.SLIDE
	actionTimer = 0.5
	velocity.x = 500.0 * direction

func update_action():
	match actionState:
		ActionState.SLIDE:
			velocity.x = move_toward(velocity.x, 0, 25)
		_:
			velocity.x = move_toward(velocity.x, 0, SPEED)

func acting():
	return actionState != ActionState.IDLE

func can_jump():
	if acting():
		return false
	if remJumps > 0:
		return true
	return is_on_floor()

func maxJumps():
	if hasBoots():
		return 2
	else:
		return 1

func hasBoots():
	var f = State.getFlag(StateClass.FlagNames.UPGRADES)
	return f & 1 == 1

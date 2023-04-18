extends CharacterBody2D
class_name Player

enum MoveState {IDLE, RUN, RAISING, FALLING, CROUCHING, LADDER, LADDER_UP, LADDER_DOWN}
enum ActionState {IDLE, SLIDE, ATTACK}

@export var anim: AnimatedSprite2D
@export var standCollision: CollisionShape2D
@export var attackRoot: AttackLibrary
@export var walkParticles: GPUParticles2D

const SPEED = 150.0
const JUMP_VELOCITY = -270.0
const JUMP_TIME = 0.10
const MAX_Y_VELOCITY = 400.0

var hudRef = null

var currDmg = 0
var invincTimer = 0.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumping = false
var jumpTime= 0
var moveState= MoveState.IDLE
var actionState = ActionState.IDLE
var actionTimer = 0
var remJumps=0
var ladderCount=0
var inLadder = false
var lastLadderX = 0

func _physics_process(delta):
	# Particles update
	walkParticles.emitting = (is_on_floor() && abs(velocity.x) > 200)
	# Invincibility frames
	if invincTimer > 0:
		updateInvincTime(delta)
	# Acting update
	if actionState != ActionState.IDLE:
		actionTimer -= delta
		if actionTimer <= 0:
			actionState = ActionState.IDLE
			attackRoot.unsetAttack()
	# Add the gravity.
	if not is_on_surface():
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
		resetLadder()
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
	if direction and isMovingAction() and !isInLadder():
		moveState = MoveState.RUN
		standCollision.disabled = false
		if not acting():
			anim.flip_h = direction < 0
			attackRoot.scale.x = direction
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
	if not is_on_surface():
		if velocity.y < 0:
			moveState = MoveState.RAISING
		elif velocity.y > 0:
			moveState = MoveState.FALLING
	if isInLadder():
		moveState = MoveState.LADDER
		if Input.is_action_pressed("ui_down"):
			moveState = MoveState.LADDER_UP
			position.y += 2
		elif Input.is_action_pressed("ui_up"):
			moveState = MoveState.LADDER_DOWN
			position.y -= 2
	elif ladderCount > 0:
		if Input.is_action_pressed("ui_down") || Input.is_action_pressed("ui_up"):
			getOnLadder()
	elif Input.is_action_pressed("ui_down") and not acting():
		moveState = MoveState.CROUCHING
		standCollision.disabled = true
		velocity.x = 0
	if Input.is_action_just_pressed("ui_cancel") and not acting():
		action_attack(direction)
	updateAnimation()
	move_and_slide()

func updateInvincTime(delta):
	invincTimer -= delta
	if (invincTimer <= 0):
		#anim.visible = true
		anim.modulate = Color.WHITE
	else:
		var f = int(invincTimer * 10)
		anim.modulate = Color.RED if f%2==0 else Color.WHITE
func updateAnimation():
	match actionState:
		ActionState.ATTACK:
			match moveState:
				MoveState.IDLE:
					anim.play("attackStand")
				MoveState.RUN:
					anim.play("attackRun")
				MoveState.RAISING,MoveState.FALLING:
					anim.play("attackAir")
				MoveState.CROUCHING:
					anim.play("attackCrouch")
				MoveState.LADDER,MoveState.LADDER_UP,MoveState.LADDER_DOWN:
					anim.play("attackLadder")
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
				MoveState.LADDER:
					anim.play("ladder")
				MoveState.LADDER_UP,MoveState.LADDER_DOWN:
					anim.play("ladderMove")

func action_attack(direction):
	actionState = ActionState.ATTACK
	actionTimer = 0.2
	match moveState:
		MoveState.IDLE, MoveState.LADDER, MoveState.LADDER_UP, MoveState.LADDER_DOWN:
			attackRoot.setAttack(1)
		MoveState.RUN: 
			velocity.x = 600.0 * direction
			attackRoot.setAttack(2)
		MoveState.RAISING, MoveState.FALLING:
			attackRoot.setAttack(2)
		MoveState.CROUCHING:
			attackRoot.setAttack(0)
func action_slide(direction):
	if !hasBoots():
		return
	actionState = ActionState.SLIDE
	actionTimer = 0.5
	velocity.x = 500.0 * direction
	attackRoot.setAttack(0)
func update_action():
	match actionState:
		ActionState.SLIDE:
			velocity.x = move_toward(velocity.x, 0, 25)
		_:
			velocity.x = move_toward(velocity.x, 0, SPEED)
func acting():
	return actionState != ActionState.IDLE
func isMovingAction():
	match actionState:
		ActionState.IDLE:
			return true
		ActionState.SLIDE:
			return false
		ActionState.ATTACK:
			match moveState:
				MoveState.RAISING,MoveState.FALLING:
					return true
				MoveState.IDLE,MoveState.RUN,MoveState.CROUCHING,MoveState.LADDER,MoveState.LADDER_UP,MoveState.LADDER_DOWN:
					return false

func is_on_surface():
	return is_on_floor() || isInLadder()

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

# ==============================================================================
# DAMAGEABLE "INTERFACE" (duck-typing sucks)
# ==============================================================================
func remLifes():
	return maxLifes() - currDmg
func maxLifes():
	var f = State.getFlag(StateClass.FlagNames.LIFE)
	return 2 + f*2
func isDamageable():
	return true
func damage(value:int,kind:Damageable.DamageType):
	if (invincTimer > 0):
		return
	if (kind != Damageable.DamageType.PLAYER):
		invincTimer = 1
		currDmg = min((currDmg + value),maxLifes())
		refresh()
		if currDmg == maxLifes():
			die()
func die():
	print("Oops I'm ded.")
func refresh():
	hudRef.refreshLifes()

# ==============================================================================
# Ladder
# ==============================================================================
func setLadder(x):
	lastLadderX = x
	ladderCount += 1
func unsetLadder():
	ladderCount -= 1
	if ladderCount <= 0:
		ladderCount = 0
		inLadder = false
func isInLadder():
	return inLadder
func getOnLadder():
	position.x = lastLadderX
	velocity.y = 0
	inLadder = true
func resetLadder():
	inLadder = false

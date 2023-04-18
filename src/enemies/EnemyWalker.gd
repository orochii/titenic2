extends CharacterBody2D

enum MoveState {IDLE, RUN}
enum ActionState {IDLE, ATTACK}

const SPEED = 100.0
const JUMP_VELOCITY = -250.0

@export var max_Lifes = 2
@export var anim: AnimatedSprite2D
@export var attackRoot: AttackLibrary
@export var onDeathFX: PackedScene

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var moveState= MoveState.IDLE
var actionState= ActionState.IDLE
var actionTimer = 0
var currDmg = 0
var invincTimer = 0.0
var direction = 1
var aiTimer = 0
var queuedJump = false
var queuedAttack = false

func _physics_process(delta):
	# Invincibility frames
	if invincTimer > 0:
		updateInvincTime(delta)
	# Acting update
	if actionState != ActionState.IDLE:
		actionTimer -= delta
		if actionTimer <= 0:
			actionState = ActionState.IDLE
			attackRoot.unsetAttack()
	# Gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	# Handle Jump.
	if is_on_floor() and should_jump():
		velocity.y = JUMP_VELOCITY
		queuedJump = false
	# Handle attack.
	if queuedAttack:
		action_attack()
		queuedAttack = false
	# Horizontal movement.
	update_direction(delta)
	if direction:
		velocity.x = direction * SPEED
		moveState = MoveState.RUN
		if not acting():
			anim.flip_h = direction < 0
			attackRoot.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	updateAnimation()
	move_and_slide()

# Timing stuff
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
			anim.play("attack")
		ActionState.IDLE:
			match moveState:
				MoveState.IDLE:
					anim.play("idle")
				MoveState.RUN:
					anim.play("run")

# Actions
func acting():
	return actionState != ActionState.IDLE
func action_attack():
	actionState = ActionState.ATTACK
	actionTimer = 0.2
	attackRoot.setAttack(0)

# AI
func should_jump():
	return queuedJump
func update_direction(delta):
	aiTimer -= delta
	# Check for closeness to player
	var pPos = State.player.global_position
	var sPos = global_position
	var xDiff = pPos.x - sPos.x
	var yDiff = pPos.y - sPos.y - 12
	# Do nothing if way too far from screen
	if (abs(xDiff) > 96 || abs(yDiff) > 48):
		# Ignore player
		if aiTimer < 0:
			direction = randi_range(-1, 1)
			aiTimer = randf_range(1,4)
	else:
		aiTimer -= delta*2
		# Target player
		if (abs(xDiff) > 16 || abs(yDiff) > 24):
			# Go towards player
			direction = sign(xDiff)
			# Random action
			if aiTimer < 0:
				var r = randi_range(0, 5)
				match (r):
					1,2:
						queuedJump = true
					3:
						queuedAttack = true
				aiTimer = randf_range(1,4)
		else:
			# Stand and attack! (?)
			direction = 0
			# Random action
			if aiTimer < 0:
				var r = randi_range(0, 5)
				match (r):
					1:
						queuedJump = true
					_:
						queuedAttack = true
				aiTimer = randf_range(1,4)

# ==============================================================================
# DAMAGEABLE "INTERFACE" (duck-typing sucks)
# ==============================================================================
func remLifes():
	return maxLifes() - currDmg
func maxLifes():
	return max_Lifes
func isDamageable():
	return true
func damage(value:int,kind:Damageable.DamageType):
	if (invincTimer > 0):
		return
	if (kind != Damageable.DamageType.ENEMY):
		invincTimer = 0.2
		currDmg = min((currDmg + value),maxLifes())
		if currDmg == maxLifes():
			die()
func die():
	var fx = onDeathFX.instantiate() as Node2D
	fx.global_position = global_position
	self.queue_free()

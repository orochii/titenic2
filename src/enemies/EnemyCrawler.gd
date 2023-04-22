extends EnemyBase

@export var SPEED = 50.0
@export var floorCast:RayCast2D
@export var wallCast:RayCast2D
@export var attackDetect:ShapeCast2D
@export var projectile: PackedScene = null
@export var projectileL: PackedScene = null
@export var projectileR: PackedScene = null

var direction = 1
var attackTimer = 0

func _ready():
	floorCast.add_exception(self)
	wallCast.add_exception(self)

func _physics_process(delta):
	# Invincibility frames
	if invincTimer > 0:
		updateInvincTime(delta)
	# Attack
	if attackTimer <= 0:
		if shouldAttack():
				attack()
	else:
		attackTimer -= delta
	# Movement
	if (direction==0):
		return
	checkDirection()
	var move = Vector2(direction,1)
	var mt = global_transform.basis_xform(move)
	velocity = mt * SPEED
	move_and_slide()

func shouldAttack():
	if attackDetect==null: return true
	if attackDetect.is_colliding():
		var t = attackDetect.get_collider(0)
		if t.name == "Player":
			return true
	return false

func attack():
	# Spawn projectile(s)
	if projectile != null: spawnProjectile(projectile)
	if projectileL != null: spawnProjectile(projectileL)
	if projectileR != null: spawnProjectile(projectileR)
	attackTimer = 1

func spawnProjectile(proto):
	var p = proto.instantiate() as Node2D
	p.ignore(self)
	get_parent().add_child(p)
	p.global_position = global_position + global_transform.basis_xform(Vector2(0,-4))
	p.global_rotation = global_rotation

func checkDirection():
	if !floorCast.is_colliding() || wallCast.is_colliding():
		setDirection(-direction)
	else: setDirection(direction)

func setDirection(d:int):
	direction = d
	if (d==0): return
	floorCast.position.x = abs(floorCast.position.x)*d
	wallCast.position.x = abs(wallCast.position.x)*d
	wallCast.target_position.x = abs(wallCast.target_position.x)*d

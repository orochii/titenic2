extends Node2D

@export_category("Enemy Config")
@export var enemyPrototype:PackedScene
@export var positions:Node2D
@export var cooldown:float = 0
@export var onDeathCooldown:float = 0
@export_category("Collectables")
@export var collectables:Array[PackedScene]
@export var baseChance:float = 0.4
@export var chancePlus:float = 0.2

var timer:float = 0
var currentChance:float = 0
var currentCount:int = 0
var isPlayerInArea = false

func areaLimit():
	return positions.get_child_count()
func getPosition():
	return positions.get_child(currentCount)

func _process(delta):
	if timer > 0:
		timer -= delta
		return
	if isPlayerInArea:
		return
	if currentCount < areaLimit():
		print("Spawned enemy")
		spawnEnemy()

func spawnEnemy():
	var e = enemyPrototype.instantiate() as Node2D
	get_parent().add_child(e)
	var p = getPosition()
	e.global_position = p.global_position
	e.rotation = p.rotation
	e.connect("death", onEnemyDeath)
	currentCount += 1
	timer = cooldown

func onEnemyDeath(pos:Vector2):
	if currentCount >= areaLimit():
		timer = onDeathCooldown
	currentCount -= 1
	var r = randf()
	if (r < baseChance+currentChance):
		spawnCollectable(pos)
		currentChance = 0
	else:
		currentChance += chancePlus

func spawnCollectable(pos:Vector2):
	if collectables.size() > 0:
		var r = randi_range(0, collectables.size()-1)
		var c = collectables[r].instantiate()
		get_parent().add_child(c)
		c.global_position = pos

func _on_body_entered(body):
	if (body.name == "Player"):
		isPlayerInArea = true

func _on_body_exited(body):
	if (body.name == "Player"):
		isPlayerInArea = false

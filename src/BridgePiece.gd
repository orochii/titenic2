class_name BridgePiece

extends Area2D

@export var sprite : Sprite2D
@export var maxOffset = 2
@export var prev : BridgePiece
@export var next : BridgePiece

var bodies = []
var neighborPressed = 0

var baseName = ""
var pieceIndex = 0

func _ready():
	get_pattern()
	prev = find_sibling(-1)
	next = find_sibling(1)

func get_pattern():
	var regex = RegEx.new()
	regex.compile("[0-9]+$")
	var result = regex.search(name)
	if result:
		baseName = name.substr(0, name.length()-result.get_string().length())
		pieceIndex = result.get_string().to_int()

func find_sibling(dir):
	var sibling_name = baseName + str(pieceIndex+dir)
	return get_parent().get_node(sibling_name)

func _on_body_entered(body):
	if !body.is_class("CharacterBody2D"):
		return
	if (!bodies.has(body)):
		bodies.push_back(body)
	refreshPosition()
	updateNeighbors()

func _on_body_exited(body):
	if (bodies.has(body)):
		bodies.erase(body)
	refreshPosition()
	updateNeighbors()

func refreshPosition():
	if (bodies.size() > 0):
		sprite.position = Vector2(0, maxOffset)
	else:
		if neighborPressed==0:
			sprite.position = Vector2(0, 0)
		else:
			sprite.position = Vector2(0, maxOffset/2)

func updateNeighbors():
	var dir = 1 if (bodies.size() > 0) else -1
	if (prev != null):
		prev.neighborPressed += dir
		prev.refreshPosition()
	if (next != null):
		next.neighborPressed += dir
		next.refreshPosition()

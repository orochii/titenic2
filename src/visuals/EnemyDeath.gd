extends Node2D

@export var life:int
@export var particles:GPUParticles2D

var timer = 0

func _ready():
	particles.emitting = true

func _process(delta):
	timer += delta
	if life < timer:
		queue_free()

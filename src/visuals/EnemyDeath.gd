extends Node2D

@export var life:float
@export var particles:GPUParticles2D

var timer:float = 0

func _ready():
	if (particles != null): particles.emitting = true

func _process(delta):
	timer += delta
	if life < timer:
		queue_free()

extends StaticBody2D

@export var enabledOnStart:bool = false
@export var triggerOnEnable:Node2D = null
@export var triggerOnDisable:Node2D = null

var enabled = false
var orig_collision_layer = 0
var orig_collision_mask = 0

func _ready():
	orig_collision_layer = collision_layer
	orig_collision_mask = collision_mask
	setBarrier(enabledOnStart)

func setBarrier(enable:bool):
	# Set mask
	collision_layer = orig_collision_layer if enable else 0
	collision_mask = orig_collision_mask if enable else 0
	# When state changes
	if (enabled != enable):
		if enable:
			trigger(triggerOnEnable)
		else:
			trigger(triggerOnDisable)
		enabled = enable

func trigger(t):
	if t != null && t.has_method("interact"):
		t.interact()

func interact():
	setBarrier(!enabled)

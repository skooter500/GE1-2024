class_name SteeringBehavior extends Node

@export var weight = 1.0
@export var draw_gizmos = true

var boid

@export var enabled = true: get = is_enabled, set = set_enabled

func set_enabled(e):
	enabled = e 
	set_process(enabled)

func is_enabled():
	return enabled
	
func on_draw_gizmos():
	pass
	
func _process(delta):	
	if draw_gizmos and enabled:
		on_draw_gizmos()

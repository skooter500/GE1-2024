extends CharacterBody3D

@export var speed:float=20


func _physics_process(delta: float) -> void:
	
	var v = global_transform.basis.z
	move_and_collide(v * speed * delta)

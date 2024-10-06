extends CharacterBody3D

@export var speed:float=20


func _physics_process(delta: float) -> void:	
	var v = global_transform.basis.z
	var c:KinematicCollision3D = move_and_collide(v * speed * delta)
	if c:
		var b = c.get_collider()
		b.queue_free()
		self.queue_free()
		pass


func _on_timer_timeout() -> void:
	self.queue_free()
	pass # Replace with function body.

extends Marker3D

var bullet_scene = load("res://bullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_released("shoot"):
		var bullet = bullet_scene.instantiate()
		get_parent().get_parent().add_child(bullet)
		# can_fire = false
		bullet.global_position = global_position
		bullet.global_rotation = global_rotation
	pass

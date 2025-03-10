extends CharacterBody3D

# variables
@export var speed:float = -1
@export var rot_speed = 80

# bullets
@export var bullet_scene:PackedScene
@export var bullet_spawn:Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# position.z += speed * delta # Move from the camera
	# global_position.z += speed * delta # same above
		
	# rotate_y(deg_to_rad(rot_speed) * delta) # rotates the player - y axis
	# rotate_x(deg_to_rad(rot_speed) * delta) # rotates the player - x axis
	
	var f = Input.get_axis("move_back", "move_forward")
	# translate(Vector3(0,0,f * delta * speed)) # * delta (slow frame rate (big delta), fast" (small")) 
	
	var v = Vector3()
	
	v = global_transform.basis.z
	print(v)
	
	velocity = - v * speed * f 
	
	move_and_slide()
	
	var r = Input.get_axis("turn_left", "turn_right")
	rotate_y(- deg_to_rad(rot_speed) * r * delta)
	
	DebugDraw2D.set_text("position", position)
	DebugDraw2D.set_text("global_position", position)
	
	DebugDraw2D.set_text("basis.x", transform.basis.x)
	DebugDraw2D.set_text("basis.y", transform.basis.y)
	DebugDraw2D.set_text("basis.z", transform.basis.z)

	DebugDraw2D.set_text("glo basis.x", global_transform.basis.x)
	DebugDraw2D.set_text("glo basis.y", global_transform.basis.y)
	DebugDraw2D.set_text("glo basis.z", global_transform.basis.z)
	
	if Input.is_action_pressed("shoot"):
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)		

		bullet.global_position = bullet_spawn.global_position
		bullet.global_rotation = bullet_spawn.global_rotation
		
	
	pass

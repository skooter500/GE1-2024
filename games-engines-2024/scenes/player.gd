extends MeshInstance3D


@export var speed:float = -1
@export var rospeed = 180

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	
	#position.z+=speed * delta
	
	var f = Input.get_axis("move_backward","move_forward")
	var t = Input.get_axis("turn_left","turn_right")
	translate(Vector3(0,0,f*delta*speed))
	rotate_y(t*delta*speed)
	
	#rotate_y(deg_to_rad(rospeed)*delta)
	#rotate_x(deg_to_rad(rospeed)*delta)
	#rotate_z(deg_to_rad(rospeed)*delta)
	pass

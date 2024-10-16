extends MeshInstance3D

# variables
@export var speed:float = -1
@export var rot_speed = 180

@export var rota_speed = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# position.z += speed * delta # Move from the camera
	# global_position.z += speed * delta # same above
		
	# rotate_y(deg_to_rad(rot_speed) * delta) # rotates the player - y axis
	# rotate_x(deg_to_rad(rot_speed) * delta) # rotates the player - x axis
	
	var f = Input.get_axis("move_back", "move_forward")
	translate(Vector3(0,0,f * delta * speed)) # * delta (slow frame rate (big delta), fast" (small")) 
	
	var rotation_input = Input.get_axis("turn_left", "turn_right")
	rotate_y(rotation_input * delta * rota_speed)
	pass

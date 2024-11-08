extends CSGCylinder3D

@export var velocity:Vector3 
@export var gravity:Vector3 = Vector3(0, -9.8, 0)
@export var time:float = 0 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var desired = sqrt(global_position.y / (.5 * abs(gravity.y)))
	print(desired)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if global_position.y > 0:
		time += delta
		velocity += gravity * delta
		global_position += velocity * delta		
	pass

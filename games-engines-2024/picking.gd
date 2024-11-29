extends Node3D

@onready var ray = $RayCast3D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var e:InputEventMouseButton
		var camera = $Camera3D
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * 1000
		ray.transform.origin = from
		ray.target_position = to
		ray.enabled = true
		if ray.is_colliding():
			var collider = ray.get_collider()
			print(collider)
			ray.enabled = false
		
		
		
		
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

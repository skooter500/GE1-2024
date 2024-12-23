extends Marker3D

@export var brick_scene:PackedScene

@export var radius:float = 4
@export var height:float = 10
@export var elements = 40
@export var brick_size = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	var theta = (PI * 2) / elements 
	for j in range(height):		
		for i in range(elements):		
			var t = theta * i
			
			if (j % 2) == 0:
				t += (theta * 0.5)
			
			var x = sin(t) * radius
			var z = cos(t) * radius
			var brick = brick_scene.instantiate()
			brick.position = Vector3(x, j * brick_size, z)
			brick.rotation = Vector3(0, t, 0)
			
			var m = StandardMaterial3D.new()
			var c = randf()
			m.albedo_color = Color.from_hsv(c, 1, 1)
			brick.get_node("MeshInstance3D").set_surface_override_material(0, m)
			add_child(brick)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

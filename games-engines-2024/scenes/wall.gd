extends Node3D


@export var brick_scene:PackedScene
@export var rows =10
@export var cols =100



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	
	
	for row in range(rows):
		for col in range(cols):
			var brick = brick_scene.instantiate()
			var pos=Vector3(cos(col)*PI,row,sin(col)*PI)
			
			var material = StandardMaterial3D.new()
			
			material.albedo_color = Color.from_hsv(randf_range(0, 1), 1, 1, 0.8)
			brick.get_node("Brick").material_override = material
			
			brick.position=pos
			add_child(brick)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends Node3D


@export var brick_scene:PackedScene
@export var rows =10
@export var cols =100



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var material = StandardMaterial3D.new()
	
	for row in range(rows):
		for col in range(cols):
			material.albedo_color=randi_range(0,255)
			var brick = brick_scene.instantiate()
			
			var pos=Vector3(cos(col)*PI,row,sin(col)*PI)
			
			brick.position=pos
			add_child(brick)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

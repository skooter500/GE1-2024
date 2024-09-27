extends Node3D

@export var brick_scene:PackedScene
@export var rows =10
@export var cols =10



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for row in range(rows):
		for col in range(cols):
			var brick = brick_scene.instantiate()
			var pos=Vector3(col,row,0)
			brick.position=pos
			add_child(brick)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

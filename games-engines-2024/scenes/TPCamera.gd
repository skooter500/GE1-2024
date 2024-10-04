extends Camera3D

@export var target:Node3D

@export var player:Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	global_position = lerp(global_position, target.global_position, delta * 5.0)
	look_at(player.global_position)
	
	
	
	pass

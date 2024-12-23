extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		$AudioStreamPlayer3D.play()
	pass


func _on_area_entered(area: Area3D) -> void:
	print(area)
	pass # Replace with function body.

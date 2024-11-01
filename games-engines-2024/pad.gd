extends Area3D


var mat:StandardMaterial3D

var out_color:Color = Color.from_hsv(.3, 1, 1, 0.1)
var in_color:Color = Color.from_hsv(.7, 1, 1, 0.1)

@export var play:bool=true



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	mat = StandardMaterial3D.new()
	$MeshInstance3D.set_surface_override_material(0, mat)
	mat.albedo_color = out_color
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_entered(area: Area3D) -> void:
	mat.albedo_color = in_color
	if play:
		$AudioStreamPlayer3D.play()
	pass # Replace with function body.


func _on_area_exited(area: Area3D) -> void:
	mat.albedo_color = out_color
	pass # Replace with function body.

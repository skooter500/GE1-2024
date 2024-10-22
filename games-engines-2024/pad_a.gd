extends Area3D

var mat:StandardMaterial3D

@export var out_color:Color
@export var in_color:Color

var toggle:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	mat = StandardMaterial3D.new()
	$MeshInstance3D.set_surface_override_material(0, mat)
	mat.albedo_color = out_color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_mat():
	if toggle:
		mat.albedo_color = in_color
	else:
		mat.albedo_color = out_color
		
func _on_area_entered(area: Area3D) -> void:
	toggle = ! toggle
	set_mat()	
	pass # Replace with function body.

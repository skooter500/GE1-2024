extends Node3D

@export var quads_per_tile: int = 10
@export var height_scale: float = 10.0  
@export var width_scale: float = 10.0  
@export var perlin_scale: float = 0.1
@export var speed: float = 1.0
@export var material: Material

@export var low:float = 1
@export var high:float = 0


var mesh_instance: MeshInstance3D
var collision_shape: CollisionShape3D
var current_mesh: ArrayMesh
var t: float = 0.0

func _enter_tree():
	await get_tree().process_frame
	generate_mesh()

func _ready():
	pass

func sample_cell(row: float, col: float) -> float:
	var world_pos = global_position
	var sample_x = ((col * width_scale) + world_pos.x) * perlin_scale
	var sample_z = ((row * width_scale) + world_pos.z) * perlin_scale
	var noise = noise_2d(sample_x, sample_z)
	var mid = 0.5
	if noise > high:
		noise = mid + (noise - high)
	elif noise < low:
		noise = mid + (noise - low)
	else:
		noise = mid

	var height = noise * 100
	return height

func generate_mesh():
	mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	
	var static_body = StaticBody3D.new()
	add_child(static_body)
	collision_shape = CollisionShape3D.new()
	static_body.add_child(collision_shape)
	
	create_mesh()
	
	mesh_instance.mesh = current_mesh
	mesh_instance.material_override = material
	
	var collision_shape_mesh = ConcavePolygonShape3D.new()
	collision_shape_mesh.set_faces(current_mesh.get_faces())
	collision_shape.shape = collision_shape_mesh
	
func get_normal(x: float, y: float) -> Vector3:
	var epsilon := 1
	var normal := Vector3(
		(sample_cell(x + epsilon, y) - sample_cell(x - epsilon, y)) / (2.0 * epsilon),
		1.0,
		(sample_cell(x, y + epsilon) - sample_cell(x, y - epsilon)) / (2.0 * epsilon),
	)
	return normal.normalized()


func create_mesh():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var bottom_left = Vector3(-quads_per_tile / 2.0, 0, -quads_per_tile / 2.0)
	
	# Generate vertices and triangles
	for row in range(quads_per_tile):
		for col in range(quads_per_tile):
			var bl = bottom_left + Vector3(col * width_scale, sample_cell(row, col), row * width_scale)
			var tl = bottom_left + Vector3(col * width_scale, sample_cell(row + 1, col), (row + 1) * width_scale)
			var tr = bottom_left + Vector3((col + 1) * width_scale, sample_cell(row + 1, col + 1), (row + 1) * width_scale)
			var br = bottom_left + Vector3((col + 1) * width_scale, sample_cell(row, col + 1), row * width_scale)
			
			# Calculate UVs for each vertex
			var uv_bl = Vector2(float(col) / quads_per_tile, float(row) / quads_per_tile)
			var uv_tl = Vector2(float(col) / quads_per_tile, float(row + 1) / quads_per_tile)
			var uv_tr = Vector2(float(col + 1) / quads_per_tile, float(row + 1) / quads_per_tile)
			var uv_br = Vector2(float(col + 1) / quads_per_tile, float(row) / quads_per_tile)
			
			st.set_normal(get_normal(row, col + 1))		
			st.set_uv(uv_br)	
			st.add_vertex(br)            
			
			st.set_normal(get_normal(row + 1, col))	
			st.set_uv(uv_tl)		
			st.add_vertex(tl)
			
			st.set_normal(get_normal(row, col))
			st.set_uv(uv_bl)
			st.add_vertex(bl)
						
						
			# Second triangle
			st.set_normal(get_normal(row + 1, col + 1))
			st.set_uv(uv_tr)
			st.add_vertex(tr)
			
			st.set_normal(get_normal(row + 1, col))
			st.set_uv(uv_tl)
			st.add_vertex(tl)
			
			st.set_normal(get_normal(row, col + 1))
			st.set_uv(uv_br)
			st.add_vertex(br)
			
	
	st.generate_tangents()
	# st.generate_normals()
	current_mesh = st.commit()

func noise_2d(x: float, y: float) -> float:
	var noise = FastNoiseLite.new()
	noise.seed = 1234
	noise.frequency = 1.0
	return (noise.get_noise_2d(x, y) + 1.0) / 2.0

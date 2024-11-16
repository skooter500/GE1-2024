extends Node3D

@export var quads_per_tile: int = 10
@export var height_scale: float = 10.0  
@export var width_scale: float = 10.0  
@export var perlin_scale: float = 0.1
@export var speed: float = 1.0
@export var material: Material
@export var noise_octaves: int = 4
@export var noise_persistence: float = 0.5
@export var noise_lacunarity: float = 2.0

var mesh_instance: MeshInstance3D
var collision_shape: CollisionShape3D
var current_mesh: ArrayMesh
var t: float = 0.0
var noise: FastNoiseLite

func _enter_tree():
	initialize_noise()
	await get_tree().process_frame
	generate_mesh()

func initialize_noise():
	noise = FastNoiseLite.new()
	noise.seed = 1234
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.005  # Lowered frequency for more visible variations
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = noise_octaves
	noise.fractal_lacunarity = noise_lacunarity
	noise.fractal_gain = noise_persistence

func sample_cell(row: float, col: float) -> float:
	var world_pos = global_position
	
	# Calculate world coordinates
	var sample_x = (col * width_scale + world_pos.x)
	var sample_z = (row * width_scale + world_pos.z)
	
	# Get height from noise
	var height = noise.get_noise_2d(sample_x, sample_z)
	
	# Transform from [-1, 1] to [0, 1] range and apply height scale
	height = (height + 1.0) * 0.5 * height_scale
	
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

func create_mesh():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var bottom_left = Vector3(-quads_per_tile / 2.0, 0, -quads_per_tile / 2.0)
	
	# Create vertices array for the entire grid
	var vertices = []
	var grid_size = quads_per_tile + 1
	
	# First pass: Generate all vertices
	for row in range(grid_size):
		var vertex_row = []
		for col in range(grid_size):
			var x = col * width_scale
			var z = row * width_scale
			var height = sample_cell(row, col)
			var vertex = bottom_left + Vector3(x, height, z)
			vertex_row.append(vertex)
		vertices.append(vertex_row)
	
	# Second pass: Generate triangles using the vertex grid
	for row in range(quads_per_tile):
		for col in range(quads_per_tile):
			var bl = vertices[row][col]
			var tl = vertices[row + 1][col]
			var tr = vertices[row + 1][col + 1]
			var br = vertices[row][col + 1]
			
			# Calculate UVs
			var uv_bl = Vector2(float(col) / quads_per_tile, float(row) / quads_per_tile)
			var uv_tl = Vector2(float(col) / quads_per_tile, float(row + 1) / quads_per_tile)
			var uv_tr = Vector2(float(col + 1) / quads_per_tile, float(row + 1) / quads_per_tile)
			var uv_br = Vector2(float(col + 1) / quads_per_tile, float(row) / quads_per_tile)
			
			# First triangle (bl, br, tl)
			var normal1 = (br - bl).cross(tl - bl).normalized()
			st.set_normal(normal1)
			st.set_uv(uv_bl)
			st.add_vertex(bl)
			
			st.set_normal(normal1)
			st.set_uv(uv_br)
			st.add_vertex(br)
			
			st.set_normal(normal1)
			st.set_uv(uv_tl)
			st.add_vertex(tl)
			
			# Second triangle (br, tr, tl)
			var normal2 = (tr - br).cross(tl - br).normalized()
			st.set_normal(normal2)
			st.set_uv(uv_br)
			st.add_vertex(br)
			
			st.set_normal(normal2)
			st.set_uv(uv_tr)
			st.add_vertex(tr)
			
			st.set_normal(normal2)
			st.set_uv(uv_tl)
			st.add_vertex(tl)
	
	st.generate_tangents()
	current_mesh = st.commit()

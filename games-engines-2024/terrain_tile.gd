extends Node3D

@export var quads_per_tile: int = 10
@export var height_scale: float = 10.0  
@export var width_scale: float = 10.0  
@export var perlin_scale: float = 0.1
@export var speed: float = 1.0
@export var material: Material
@export var noise_octaves: int = 4  # Number of noise layers
@export var noise_persistence: float = 0.5  # How much each octave contributes
@export var noise_lacunarity: float = 2.0  # How frequency changes between octaves
@export var plateau_height: float = 0.7  # Height at which plateaus form
@export var valley_depth: float = 0.3  # Depth of valleys
@export var terrain_roughness: float = 1.5  # Overall terrain roughness

var mesh_instance: MeshInstance3D
var collision_shape: CollisionShape3D
var current_mesh: ArrayMesh
var t: float = 0.0
var noise: FastNoiseLite

func _enter_tree():
	noise = FastNoiseLite.new()
	noise.seed = randi()  # Random seed each time
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	await get_tree().process_frame
	generate_mesh()

func _ready():
	pass

func sample_cell(row: float, col: float) -> float:
	var world_pos = global_position
	
	# Get base coordinates
	var base_x = ((col * width_scale) + world_pos.x) * perlin_scale
	var base_z = ((row * width_scale) + world_pos.z) * perlin_scale
	
	# Generate multilayered noise (octaves)
	var amplitude: float = 1.0
	var frequency: float = 1.0
	var height: float = 0.0
	var max_possible_height: float = 0.0
	
	# Add multiple layers of noise
	for i in noise_octaves:
		var sample_x = base_x * frequency
		var sample_z = base_z * frequency
		
		# Get noise value and shape it
		var noise_val = noise.get_noise_2d(sample_x, sample_z)
		height += noise_val * amplitude
		
		# Keep track of maximum possible height for normalization
		max_possible_height += amplitude
		
		# Adjust for next octave
		amplitude *= noise_persistence
		frequency *= noise_lacunarity
	
	# Normalize height to 0-1 range
	height = (height + max_possible_height) / (max_possible_height * 2.0)
	
	# Apply terrain shaping functions
	height = shape_terrain(height)
	
	# Scale the final height
	return height * height_scale

func shape_terrain(height: float) -> float:
	# Create plateaus
	if height > plateau_height:
		var plateau_factor = (height - plateau_height) / (1.0 - plateau_height)
		height = plateau_height + (plateau_factor * plateau_factor * (1.0 - plateau_height))
	
	# Deepen valleys
	if height < valley_depth:
		var valley_factor = height / valley_depth
		height = height * (valley_factor * valley_factor)
	
	# Apply overall terrain roughness
	height = pow(height, terrain_roughness)
	
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
			
			# First triangle (bl, br, tl) - counter-clockwise order
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
			
			# Second triangle (br, tr, tl) - counter-clockwise order
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

func noise_2d(x: float, y: float) -> float:
	return (noise.get_noise_2d(x, y) + 1.0) / 2.0

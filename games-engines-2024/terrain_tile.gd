extends Node3D

@export var quads_per_tile: int = 10
@export var height_scale: float = 10.0  
@export var width_scale: float = 10.0  
@export var perlin_scale: float = 0.1
@export var speed: float = 1.0
@export var material: Material

var mesh_instance: MeshInstance3D
var collision_shape: CollisionShape3D
var current_mesh: ArrayMesh
var t: float = 0.0

# Wait until positioned in scene before generating
func _enter_tree():
	# Let a frame pass so our position is set
	await get_tree().process_frame
	generate_mesh()

# Remove the mesh generation from _ready
func _ready():
	pass

func sample_cell(row: float, col: float) -> float:
	# Get the tile's world position
	var world_pos = global_position
	
	# Add the world position to the sampling coordinates
	var sample_x = ((col * width_scale) + world_pos.x) * perlin_scale
	var sample_z = ((row * width_scale) + world_pos.z) * perlin_scale
	
	return noise_2d(sample_x, sample_z) * height_scale
	
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
			
			# Calculate normal for first triangle
			
			st.add_vertex(br)            
			st.add_vertex(tl)
			st.add_vertex(bl)
			
			
			# Second triangle
			st.add_vertex(tr)
			st.add_vertex(tl)
			st.add_vertex(br)
	
			st.generate_normals()
	# We might not need generate_normals() anymore since we're setting them manually
	# st.generate_normals()
	current_mesh = st.commit()

func noise_2d(x: float, y: float) -> float:
	# Simple implementation of 2D noise using FastNoiseLite
	var noise = FastNoiseLite.new()
	noise.seed = 1234
	noise.frequency = 1.0
	return (noise.get_noise_2d(x, y) + 1.0) / 2.0

#func _process(delta: float):
	#var st = SurfaceTool.new()
	#st.begin(Mesh.PRIMITIVE_TRIANGLES)
	#
	#var bottom_left = Vector3(-quads_per_tile / 2.0, 0, -quads_per_tile / 2.0)
	#
	## Generate vertices and triangles with updated heights
	#for row in range(quads_per_tile):
		#for col in range(quads_per_tile):
			#var bl = bottom_left + Vector3(col, sample_cell(row + t, col + t), row)
			#var tl = bottom_left + Vector3(col, sample_cell(row + 1 + t, col + t), row + 1)
			#var tr = bottom_left + Vector3(col + 1, sample_cell(row + 1 + t, col + 1 + t), row + 1)
			#var br = bottom_left + Vector3(col + 1, sample_cell(row + t, col + 1 + t), row)
			#
			## First triangle (in the corrected order you found)
			#st.add_vertex(br)
			#st.add_vertex(tl)
			#st.add_vertex(bl)
			#
			## Second triangle
			#st.add_vertex(tr)
			#st.add_vertex(tl)
			#st.add_vertex(br)
	#
	#st.generate_normals()
	#current_mesh = st.commit()
	#mesh_instance.mesh = current_mesh
	#
	#var collision_shape_mesh = ConcavePolygonShape3D.new()
	#collision_shape_mesh.set_faces(current_mesh.get_faces())
	#collision_shape.shape = collision_shape_mesh
	#
	#t += speed * delta
	#print(t)

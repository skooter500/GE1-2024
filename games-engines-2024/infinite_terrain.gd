extends Node3D

@export var tile_prefab: PackedScene
@export var player: Node3D
@export var half_tile: int = 5

var old_game_objects: Array = []
var tiles: Dictionary = {}
var start_pos: Vector3

var quads_per_tile
var width_scale

func _ready():
	# Get terrain tile info from prefab if possible
	if tile_prefab:
		var tt = tile_prefab.instantiate()
		quads_per_tile = tt.quads_per_tile
		width_scale = tt.width_scale
		tt.queue_free()
	
	# If no player set, use camera
	if !player:
		player = get_viewport().get_camera_3d()
	
	# Start the terrain generation coroutine
	generate_world_around_player()

class Tile:
	var the_tile: Node3D
	var creation_time: float
	
	func _init(t: Node3D, ct: float):
		the_tile = t
		creation_time = ct

func generate_world_around_player():
	# Make sure this happens at once at the start
	var x_move: int = 9223372036854775807  # Equivalent to int.MaxValue
	var z_move: int = 9223372036854775807
	
	while true:
		if old_game_objects.size() > 0:
			var obj = old_game_objects.pop_front()
			obj.queue_free()
			
		var tile_width = quads_per_tile * width_scale
		if abs(x_move) >= tile_width or abs(z_move) >= tile_width:
			var update_time = Time.get_ticks_msec() / 1000.0
			
			# Force integer position and round to nearest tilesize
			var player_x = floor(player.position.x / tile_width) * tile_width
			var player_z = floor(player.position.z / tile_width) * tile_width
			
			var new_tiles: Array = []
			
			# Generate positions for new tiles
			for x in range(-half_tile, half_tile):
				for z in range(-half_tile, half_tile):
					var pos = Vector3(
						x * tile_width + player_x,
						0,
						z * tile_width + player_z
					)
					
					var tilename = "Tile_%d_%d" % [int(pos.x), int(pos.z)]
					if !tiles.has(tilename):
						new_tiles.append(pos)
					else:
						tiles[tilename].creation_time = update_time
			
			# Sort tiles by distance from player
			new_tiles.sort_custom(func(a: Vector3, b: Vector3) -> bool:
				return player.position.distance_squared_to(a) < player.position.distance_squared_to(b)
			)
			
			# Create new tiles
			for pos in new_tiles:
				var t = tile_prefab.instantiate()
				add_child(t)
				t.position = pos
				
				var tilename = "Tile_%d_%d" % [int(pos.x), int(pos.z)]
				t.name = tilename
				
				var tile = Tile.new(t, update_time)
				tiles[tilename] = tile
				await get_tree().process_frame
			
			# Clean up old tiles
			var new_terrain: Dictionary = {}
			for tile in tiles.values():
				if tile.creation_time != update_time:
					old_game_objects.append(tile.the_tile)
				else:
					new_terrain[tile.the_tile.name] = tile
			
			# Update tiles dictionary
			tiles = new_terrain
			start_pos = player.position
		
		await get_tree().process_frame
		
		# Determine how far the player has moved since last terrain update
		x_move = int(player.position.x - start_pos.x)
		z_move = int(player.position.z - start_pos.z)

func _process(_delta: float):
	# Empty _process function to maintain parity with Unity script
	pass

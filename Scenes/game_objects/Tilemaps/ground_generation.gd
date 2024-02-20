extends TileMap

@export var biome_list: Array[Biome]
@export var chunk_size: int = 16
@export var loaded_chunk_size = 16
@export var max_biome_size = 20


var previous_cell: Vector2i = Vector2i.ZERO
var selection_layer: int = 2
var chunk_dictionary: Dictionary = {}
var layer_dictionary: Dictionary = {}
var biome_table : WeightedTable = WeightedTable.new()
var current_biome: Biome
var current_biome_count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	biome_loader()
	if chunk_dictionary.size() == 0:
		chunk_loader(Vector2i.ZERO)
	add_layer(get_layers_count())
	selection_layer = get_layers_count()-1
	set_layer_name(selection_layer, "selection_layer")


func biome_loader():
	if biome_list.size()>0:
		set_layer_name(0, "ground_base")
		layer_dictionary["ground_base"] = 0
		add_layer(1)
		set_layer_name(1, "ground_stitch")
		layer_dictionary["ground_stitch"] = 1
	var has_scatter = false
	for biome in biome_list:
		biome.load_tables()
		if biome.terrain_scatter.size() > 0:
			has_scatter = true
		biome_table.add_item(biome, biome.percentage_chance)
		
		for exlude_biome in biome_list:
			if biome.connecting_biomes_id.size() > 0:
				if exlude_biome != biome && !biome.connecting_biomes_id.has(exlude_biome.id):
					biome.non_connecting_biomes.append(exlude_biome)
			elif exlude_biome != biome:
				biome.non_connecting_biomes.append(exlude_biome)
	if has_scatter == true:
		add_layer(2)
		set_layer_name(2, "ground_scatter")
		layer_dictionary["ground_scatter"] = 2


func pick_biome(current_chunk: Vector2i):
	if current_biome == null:
		current_biome_count += 1
		return biome_table.pick_item()
	else:
		var cardinal_neighbors = look_at_neighbor_chunks(current_chunk)
		var adjusted_weight = get_adjusted_biome_weights(cardinal_neighbors)
		adjusted_weight = (adjusted_weight * (max_biome_size - current_biome_count)*2)
		var new_biome = biome_table.pick_item(current_biome.non_connecting_biomes, current_biome, adjusted_weight)
		if new_biome != current_biome:
			current_biome_count = 0
		else:
			current_biome_count += 1
		return new_biome


func get_adjusted_biome_weights(neighbor_biomes: Dictionary):
	var adjusted_weight: float = current_biome.percentage_chance
	var keys = neighbor_biomes.keys()
	for key in keys:
		if chunk_dictionary[neighbor_biomes[key]]["biome"] == current_biome:
			adjusted_weight += current_biome.percentage_chance
	return adjusted_weight/100


func look_at_neighbor_chunks(current_chunk: Vector2i):
	var neighbor_vectors = {
		"north" : current_chunk + Vector2i(0,-1),
		"south" : current_chunk + Vector2i(0,1),
		"east" : current_chunk + Vector2i(-1,0),
		"west" : current_chunk + Vector2i(1,0),
		"north_east" : current_chunk + Vector2i(-1,-1),
		"south_east" : current_chunk + Vector2i(-1,1),
		"north_west" : current_chunk + Vector2i(-1,-1),
		"south_west" : current_chunk + Vector2i(1,1)
	}
	var cardinal_neighbors: Dictionary = {}
	var cardinal_directions = neighbor_vectors.keys()
	for direction in cardinal_directions:
		if chunk_dictionary.has(neighbor_vectors[direction]):
			cardinal_neighbors[direction] =  neighbor_vectors[direction]
			print(direction)
	return cardinal_neighbors
	


func chunk_loader(starting_chunk: Vector2i):
	var current_terrain : Terrain
	for x in loaded_chunk_size:
		for y in loaded_chunk_size:
			var current_chunk = Vector2i(x-loaded_chunk_size/2,y-loaded_chunk_size/2)
			current_biome = pick_biome(current_chunk)
			if !current_terrain:
				current_terrain = current_biome.terrain_table.pick_item()
			else:
				current_terrain = current_biome.terrain_table.pick_item([],current_terrain, 10)
			var neighbors = look_at_neighbor_chunks(current_chunk)
			var ending_directions: Array[Vector2i] = []
			if neighbors.size() > 0:
				for key in neighbors.keys():
					if chunk_dictionary.has(neighbors[key]):
						if chunk_dictionary[neighbors[key]]["biome"] != current_biome:
							ending_directions.append(current_chunk - neighbors[key])
			var cord_list = generate_chunk(current_terrain, current_chunk * 16, ending_directions)
			
			chunk_dictionary[current_chunk] = {
				"biome" : current_biome,
				"terrain": current_terrain,
				"tile_cords" : cord_list
			}


func generate_chunk(terrain: Terrain, start_cord: Vector2i, biome_end_direction: Array[Vector2i]):
	var chunk_layers: Array
	var layer = layer_dictionary["ground_base"] 
	var atlas_id = terrain.start_tile_atlas_id
	var atlas_index = terrain.start_tile_atlas_index
	
	chunk_layers = lay_terrain(layer, start_cord, atlas_id, atlas_index, chunk_size, chunk_size)
	
	if biome_end_direction.size() > 0:
		var stitch_cords: Array
		layer = layer_dictionary["ground_stitch"]
		for direction in biome_end_direction:
			if direction.x != 0 && direction.y != 0:
				continue
			var stitch_start = start_cord
			var stitch_to = start_cord
			var temp_stitch_start = start_cord
			var stitch_to_x = 0
			var stitch_to_y = 0
			var stitch_path = []
			if direction.x > 0:
				temp_stitch_start.x += (chunk_size)
				stitch_to = temp_stitch_start
				stitch_to.y += chunk_size
				while temp_stitch_start.y != stitch_to.y:
					stitch_path.append(temp_stitch_start)
					temp_stitch_start.y += 1
				stitch_start.x += (chunk_size-1)
				stitch_to_x = 1
				stitch_to_y = chunk_size
				atlas_index = Vector2i(13,1)
			elif direction.y > 0:
				temp_stitch_start.y += (chunk_size)
				stitch_to = temp_stitch_start
				stitch_to.x += chunk_size
				while temp_stitch_start.x != stitch_to.x:
					stitch_path.append(temp_stitch_start)
					temp_stitch_start.x += 1
				stitch_start.y += (chunk_size-1)
				stitch_to_x = chunk_size
				stitch_to_y = 1
				atlas_index = Vector2i(13,5)
			elif direction.x < 0:
				temp_stitch_start.x +=1
				stitch_to = temp_stitch_start
				stitch_to.y += chunk_size
				while temp_stitch_start.y != stitch_to.y:
					stitch_path.append(temp_stitch_start)
					temp_stitch_start.y += 1
				stitch_start.x += 1
				stitch_to_x = 1
				stitch_to_y = chunk_size
				atlas_index = Vector2i(1,9)
			elif direction.y < 0:
				temp_stitch_start.y += 1
				stitch_to = temp_stitch_start
				stitch_to.x += chunk_size
				while temp_stitch_start.x != stitch_to.x:
					stitch_path.append(temp_stitch_start)
					stitch_start.x += 1
				stitch_start.y += 1
				stitch_to_x = chunk_size
				stitch_to_y = 1
				atlas_index = Vector2i(19,5)
					
			if stitch_path.size() > 0:
				stitch_cords = lay_terrain(layer,stitch_start, atlas_id, atlas_index, stitch_to_x,stitch_to_y)
				stitch_path.append(stitch_to)
				set_cells_terrain_path(layer,stitch_path,terrain.terrain_set,terrain.terrain_id,false)	
#			stitch_cords.reverse()
#			set_cells_terrain_connect(layer, stitch_cords, terrain.terrain_set, terrain.terrain_id, false)
			

func lay_terrain(layer: int, start_cord: Vector2i, atlas_id, atlas_index, size_x, size_y):
	var chunk_layers: Array
	for x in size_x:
		for y in size_y:
			var current_cell = start_cord + Vector2i(x,y)
			set_cell(layer, current_cell,atlas_id, atlas_index)
			chunk_layers.append(current_cell)
	return chunk_layers


func sticth(current_chunk: Vector2i, neighbor: Vector2i, current_terrain: Terrain):
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if event is InputEventMouseMotion:
		var current_cell = local_to_map(get_local_mouse_position())
		if current_cell != previous_cell:
			set_cell(selection_layer,previous_cell)
			set_cell(selection_layer, current_cell ,2,Vector2i(0,0) )
			previous_cell = current_cell

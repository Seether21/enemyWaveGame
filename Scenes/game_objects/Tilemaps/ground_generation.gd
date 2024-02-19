extends TileMap

var previous_cell: Vector2i = Vector2i.ZERO
var selection_layer: int = 2
var chunk_dictionary: Dictionary = {}
var biome_dictionary: Dictionary

@export var chunk_height: int = 16
@export var chunk_wdith: int = 16
@export var loaded_chunk_height = 16
@export var loaded_chunk_wdith = 16

# Called when the node enters the scene tree for the first time.
func _ready():
	selection_layer = get_layers_count()-1
	if chunk_dictionary.size() == 0:
		chunk_loader(Vector2i.ZERO)


func chunk_loader(starting_chunk: Vector2i):
	for x in loaded_chunk_height:
		for y in loaded_chunk_wdith:
			var current_chunk = Vector2i(x-loaded_chunk_height/2,y-loaded_chunk_wdith/2)
			chunk_dictionary[current_chunk] = generate_chunk(0,current_chunk * 16, 1, Vector2i(1,1),0,0)
			print("Chunk " + str(current_chunk))


func generate_chunk(layer: int, starting_tile: Vector2i, starting_tile_source_id: int, starting_tile_atlas_id: Vector2i, terrain_set_id: int, terrain: int):
	var chunk_layers: Array
	for x in chunk_height:
		for y in chunk_wdith:
			var current_cell = starting_tile + Vector2i(x,y)
			set_cell(layer,starting_tile,starting_tile_source_id,starting_tile_atlas_id)
			chunk_layers.append(current_cell)
			#print("Cell: " + str(current_cell))
	set_cells_terrain_connect(layer, chunk_layers,terrain_set_id,terrain)
	return chunk_layers


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if event is InputEventMouseMotion:
		var current_cell = local_to_map(get_local_mouse_position())
		if current_cell != previous_cell:
			set_cell(selection_layer,previous_cell)
			set_cell(selection_layer, current_cell ,2,Vector2i(0,0) )
			print(current_cell)
			previous_cell = current_cell

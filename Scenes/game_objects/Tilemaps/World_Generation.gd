extends TileMap

@export var noise_range: int = 10
@export var biome_list: Array[Biome]
@export var load_chunk_size: int = 16

var player

var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude = FastNoiseLite.new()
var chunk_size = 16
var chunk_dictionary: Dictionary = {}
var loaded_chunk_dict: Array[Vector2i]
var player_previous_chunk: Vector2 = Vector2.ZERO
var selected_cell: Vector2 = Vector2.ZERO


func _ready():
	moisture.seed = randi()
	temperature.seed = randi()
	altitude.seed = randi()
	if loaded_chunk_dict.size() == 0:
		check_loaded_chunks(Vector2.ZERO)


func _process(delta):
	player = get_tree().get_first_node_in_group("player") as Node2D 
	if player != null:
		var player_pos = player.global_position
		var tile_pos = adjust_for_chunk_pos(local_to_map(player_pos))
		var player_current_chunk = get_chunk_pos(tile_pos)
		
		if player_previous_chunk != player_current_chunk:
			if loaded_chunk_dict.size()	> 0:
				var direction = player_current_chunk - player_previous_chunk
				var chunks_to_check = player_current_chunk + (direction * (load_chunk_size/2))
				#print(player_current_chunk)
				check_loaded_chunks(chunks_to_check * chunk_size, direction)
			else:
				check_loaded_chunks(tile_pos)
			player_previous_chunk = player_current_chunk
		else: player_previous_chunk = player_current_chunk
	


func check_loaded_chunks(position: Vector2, direction: Vector2 = Vector2.ZERO):
	var chunk_pos = get_chunk_pos(position)
	var start_x = chunk_pos.x - load_chunk_size / 2
	var start_y = chunk_pos.y - load_chunk_size / 2
	var end_x = load_chunk_size
	var end_y = load_chunk_size
	if direction != Vector2.ZERO:
		start_x = chunk_pos.x + direction.x
		start_y = chunk_pos.y + direction.y
		end_x = abs(direction.y) * load_chunk_size
		end_y = abs(direction.x) * load_chunk_size
	if end_x == 0:
		end_x += 2
		start_y -= load_chunk_size/2
	if end_y == 0:
		end_y += 2
		start_x -= load_chunk_size/2
		
	
	for x in end_x:
		for y in end_y:
			var check_chunk_pos = Vector2i(start_x + x, start_y + y)
			if loaded_chunk_dict.has(check_chunk_pos):
				continue
			elif chunk_dictionary.has(check_chunk_pos):
				load_chunk()
			else:
				loaded_chunk_dict.append(check_chunk_pos)
				generate_chunk(check_chunk_pos * chunk_size)
		

func get_chunk_pos(position: Vector2):
	var chunk_x = int(position.x) / chunk_size
	var chunk_y = int(position.y) / chunk_size
	
	return Vector2(chunk_x,chunk_y)


func erase_old_chunks():
	pass


func load_chunk():
	pass


func generate_chunk(position: Vector2i):
	for x in chunk_size:
		for y in chunk_size:
			var current_tile_pos = position + Vector2i(x - chunk_size / 2,y - chunk_size / 2)
			var moist = moisture.get_noise_2d(current_tile_pos.x, current_tile_pos.y)
			var temp = temperature.get_noise_2d(current_tile_pos.x, current_tile_pos.y)
			var alt = altitude.get_noise_2d(current_tile_pos.x, current_tile_pos.y)
			var chosen_biome = check_biome(current_tile_pos, alt, temp, moist)
			if chosen_biome != null:
				#print(chosen_biome.name)
				set_cell(0,current_tile_pos,chosen_biome.atlas_id,chosen_biome.atlas_coordinates)
				chunk_dictionary = {
					current_tile_pos = {
						"Biome": chosen_biome.name,
						"altitude": alt,
						"temperature": temp,
						"moisture": moist
					}
				}
			if (x == chunk_size / 2) && (y == chunk_size / 2):
				set_cell(1,current_tile_pos, 3,Vector2i(0,0))


func check_biome(pos: Vector2i, alt: float, temp: float, moist: float):
	var alt_list : Array[Biome] = []
	var temp_list: Array[Biome] = []
	var moist_list: Array[Biome] = []
	var chosen_biome: Biome
	for biome in biome_list:
		if between(alt,biome.alt_min, biome.alt_max):
			alt_list.append(biome)
	if alt_list.size() == 1:
		return alt_list[0]
	elif alt_list.size() > 1:
		for alt_biome in alt_list:
			if between(temp, alt_biome.temp_min, alt_biome.temp_max):
				temp_list.append(alt_biome)
	if temp_list.size() == 1:
		return  temp_list[0]
	if temp_list.size() > 1:
		for temp_biome in temp_list:
			if between(moist, temp_biome.moist_min, temp_biome.moist_max):
				moist_list.append(temp_biome)
	if moist_list.size() == 1:
		return moist_list[0]
	elif moist_list.size() > 1:
		return moist_list.pick_random()
	else:
		print("No biome in current range alt:" + str(alt) + " temp:" + str(temp) + " moist:" + str(moist) )


func between(value: float, min: float, max: float):
	if value > min && value < max:
		return true
		


func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_LEFT:
				var mouse_local = local_to_map(get_global_mouse_position())
				mouse_local = adjust_for_chunk_pos(mouse_local)
				var chunk = get_chunk_pos(mouse_local)
				set_cell(2,selected_cell)
				selected_cell = (chunk * chunk_size)
				set_cell(2,selected_cell, 2, Vector2i.ZERO)
				print(chunk)
	if event.is_action_pressed("ui_accept"):
		set_layer_enabled(1, !is_layer_enabled(1))


func adjust_for_chunk_pos(current_position: Vector2i):
	if current_position.x > 0:
		current_position += Vector2i(chunk_size / 2, 0)
	if current_position.x < 0:
		current_position -= Vector2i(chunk_size / 2, 0)
	if current_position.y < 0:
		current_position -= Vector2i(0, chunk_size / 2)
	if current_position.y > 0:
		current_position += Vector2i(0, chunk_size / 2)
	return current_position

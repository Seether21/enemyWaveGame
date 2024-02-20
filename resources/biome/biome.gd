extends Resource
class_name Biome

#Biome Details
@export var id: String
@export var biome_name: String
@export var percentage_chance: int = 1
@export var connecting_biomes_id: Array[String]
var non_connecting_biomes: Array[Biome]


#Generation Details
@export var terrains: Array[Terrain]
@export var terrain_percent_chance: Array[int]
var terrain_table: WeightedTable = WeightedTable.new()

#Vegetation Details
@export var terrain_scatter: Array[TerrainScatter]
@export var terrain_scatter_chance: Array[int]
var terrain_scatter_table: WeightedTable = WeightedTable.new()


func load_tables():
	if terrains.size() != 0:
		var i: int = 0
		while i < terrains.size():
			terrain_table.add_item(terrains[i], terrain_percent_chance[i])
			i += 1
	if terrain_scatter.size() != 0:
		var i: int = 0
		while i < terrain_scatter.size():
			terrain_scatter_table.add_item(terrain_scatter[i], terrain_scatter_chance[i])
			i += 1


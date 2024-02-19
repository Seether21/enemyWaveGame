extends Resource
class_name Biome

#Biome Details
@export var biome_name: String
@export var percentage_chance: float = 0
@export var connecting_biomes: Array[Biome]

#Generation Details
@export var atlas_id: int
@export var atlas_inded: Vector2i
@export var terrain_id: int
@export var terrain: int
@export var layer: int

#Vegetation Details
@export var vegetation_chance: float = 0
@export var vegetation_atlas_id: Array[int] = [0]
@export var vegetation_atlas_index: Array[Vector2i] = [Vector2i.ZERO]



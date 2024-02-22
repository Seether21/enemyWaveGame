extends Resource
class_name  Biome

@export_group("Generail Settings")
@export var id: String
@export var name: String

@export_group("Generation Settings")
#altitude of 0 is sea level
@export_range(-1, 1, .01) var alt_min: float = 0
@export_range(-1, 1, .01) var alt_max: float = 0
#temp of 0 is freezing
@export_range(-1, 1, .01) var temp_min: float = 0
@export_range(-1, 1, .01) var temp_max: float = 0
#moisture of 0 is 50%
@export_range(-1, 1, .01) var moist_min: float = 0
@export_range(-1, 1, .01) var moist_max: float = 0


@export_group("Tile info")
@export var atlas_id: int = 0
@export var atlas_coordinates: Vector2i = Vector2i(0,0)
@export_range(0, 1, .01) var scatter_chance: float = 0.0

@export_group("Terrain Scatter")
@export var scatter: Array[TerrainScatter]

extends Node2D
class_name BaseDrill

@export var drill_data: DrillData

@onready var inventory: InventoryComponent = $InventoryComponent
var timer: float = 0.0

func _ready():
	if not drill_data:
		push_error("DrillData not set for " + str(self))
		set_process(false)
	else:
		set_process(true)
		if drill_data.drill_texture:
			$Sprite2D.texture = drill_data.drill_texture

func _process(delta: float):
	timer += delta
	if timer >= drill_data.extraction_interval:
		timer = 0.0
		_extract_resource()

func _extract_resource():
	var material: MaterialData = _check_tilemaps_for_material()
	if material:
		inventory.add_resource(material, drill_data.mining_rate)
		print("Drill extracted: ", material.material_name)
	else:
		print("No material found to extract.")

# Returns the MaterialData from either OreLayer or GroundLayer at this position
func _check_tilemaps_for_material() -> MaterialData:
	var world = get_parent()
	var ore_tilemap = world.get_node_or_null("OreLayer")
	var ground_tilemap = world.get_node_or_null("GroundLayer")
	if not ore_tilemap or not ground_tilemap:
		push_error("Missing one or both tilemap layers!")
		return null

	# First check OreLayer
	var local_pos = ore_tilemap.to_local(global_position)
	var cell: Vector2i = ore_tilemap.local_to_map(local_pos)
	var material: MaterialData = _get_material_from_tilemap(ore_tilemap, cell)
	if material:
		return material

	# Fallback to GroundLayer
	local_pos = ground_tilemap.to_local(global_position)
	cell = ground_tilemap.local_to_map(local_pos)
	return _get_material_from_tilemap(ground_tilemap, cell)

func _get_material_from_tilemap(tilemap: TileMapLayer, cell: Vector2i) -> MaterialData:
	var tile_data = tilemap.get_cell_tile_data(cell)
	if tile_data:
		return tile_data.get_custom_data("Material") as MaterialData
	return null

# Drills/BaseDrill.gd
extends Node2D
class_name BaseDrill

@export var mining_rate: float = 1.0   # Units per extraction cycle
@export var fuel_usage: float = 0.5    # Amount of fuel consumed per cycle

# Optionally, you can add more common properties or functions later
func consume_fuel(fuel_amount: float) -> bool:
	#TODO
	# Placeholder logic: return true if enough fuel exists.
	# You might integrate with a global inventory or drill fuel level.
	# For now, assume always enough fuel.
	return true
	
func _get_material_from_tilemap(tilemap: TileMapLayer, cell: Vector2i) -> MaterialData:
	var tile_data = tilemap.get_cell_tile_data(cell)
	if tile_data:
		return tile_data.get_custom_data("Material") as MaterialData
	return null

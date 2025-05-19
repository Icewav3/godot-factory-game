# Drills/BaseDrill.gd
extends Node2D
class_name BaseDrill

@export var mining_rate: float = 1.0   # Units per extraction cycle
@export var fuel_usage: float = 0.5    # Amount of fuel consumed per cycle
# This gets the inventory component to store and draw from
@onready var inventory: InventoryComponent = $InventoryComponent

# local isntance vars
var mined_material: MaterialData
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

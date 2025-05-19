# Drills/BaseDrill.gd
extends Node2D
class_name BaseDrill

@export var mining_rate: float = 1.0    # Units per extraction cycle (can be used by subclasses)
@export var fuel_usage: float = 0.5     # Amount of fuel consumed per cycle (can be used by subclasses)
@onready var inventory: InventoryComponent = $InventoryComponent

var mined_material: MaterialData
var _is_paused: bool = false

func _ready() -> void:
	if inventory:
		inventory.full_changed.connect(_on_inventory_full_changed)
	else:
		printerr("Error: InventoryComponent not found on " + name + "!")
	# Ensure _process is enabled in the base class
	set_process(true)

func _process(delta: float) -> void:
	if !_is_paused:
		_perform_extraction(delta)

# This is a virtual function that subclasses will implement
func _perform_extraction(delta: float) -> void:
	push_warning("Warning: _perform_extraction() not implemented in " + name + "!")
	pass # Subclasses must override this

func consume_fuel(fuel_amount: float) -> bool:
	# Placeholder logic - subclasses can override if needed
	return true

func _get_material_from_tilemap(tilemap: TileMapLayer, cell: Vector2i) -> MaterialData:
	var tile_data = tilemap.get_cell_tile_data(cell)
	if tile_data and tile_data.has_custom_data("Material"):
		return tile_data.get_custom_data("Material") as MaterialData
	return null

func _on_inventory_full_changed(is_full: bool) -> void:
	_is_paused = is_full
	if _is_paused:
		print(name + ": Extraction paused - Inventory full.")
	else:
		print(name + ": Extraction resumed - Inventory not full.")

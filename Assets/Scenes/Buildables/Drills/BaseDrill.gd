extends Node2D
class_name BaseDrill

@export var drill_data: DrillData
@onready var inventory: InventoryComponent = $InventoryComponent

var target_material: MaterialData =  null
var timer: float = 0.0
var is_inventory_full             := false

func _ready():
	if not drill_data:
		push_error("DrillData not set for " + str(self))
		set_process(false)
	else:
		set_process(true)
		if drill_data.drill_texture:
			$Sprite2D.texture = drill_data.drill_texture
		_scan_for_material()
		inventory.full_changed.connect(_on_inventory_full_changed)

func _process(delta: float):
	if is_inventory_full:
		return

	timer += delta
	if timer >= drill_data.extraction_interval:
		timer = 0.0
	_attempt_extract()


func _scan_for_material():
	var world = get_parent()
	var ore_tilemap = world.get_node_or_null("OreLayer")
	var ground_tilemap = world.get_node_or_null("GroundLayer")
	if not ore_tilemap or not ground_tilemap:
		push_error("Missing one or both tilemap layers!")
	return

	var local_pos = ore_tilemap.to_local(global_position)
	var cell: Vector2i = ore_tilemap.local_to_map(local_pos)
	var mat            = _get_material_from_tilemap(ore_tilemap, cell)

	if not mat:
		local_pos = ground_tilemap.to_local(global_position)
		cell = ground_tilemap.local_to_map(local_pos)
		mat = _get_material_from_tilemap(ground_tilemap, cell)

	target_material = mat

func _get_material_from_tilemap(tilemap: TileMapLayer, cell: Vector2i) -> MaterialData:
	var tile_data = tilemap.get_cell_tile_data(cell)
	if tile_data:
		return tile_data.get_custom_data("Material") as MaterialData
	return null



func _attempt_extract():
	pass # To be implemented by child classes


func _on_inventory_full_changed(full: bool):
	is_inventory_full = full

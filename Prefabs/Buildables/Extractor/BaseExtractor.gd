# Drills/BaseExtractor.gd
extends Node2D
class_name BaseExtractor

@export var data: extractor_data
@onready var inventory: InventoryComponent = $InventoryComponent

var _is_paused := false
var _elapsed_time := 0.0

func _ready():
	if inventory:
		inventory.full_changed.connect(_on_inventory_full_changed)
	if not data:
		printerr("Extractor has no data assigned!")
	_create_sprite_from_data()
	set_process(true)

func _process(delta):
	if _is_paused or not data:
		return
	_elapsed_time += delta
	if _elapsed_time >= data.extraction_interval:
		_elapsed_time = 0.0
		_extract()

func _create_sprite_from_data():
	if data.sprite:
		var sprite_node = Sprite2D.new()
		sprite_node.texture = data.sprite
		add_child(sprite_node)
		sprite_node.z_index = -1  # Optional: render below other things
	else:
		printerr(name + ": No sprite assigned in data.")

func _extract():
	var world = get_parent()
	var ore_tilemap = world.get_node_or_null("OreLayer")
	var ground_tilemap = world.get_node_or_null("GroundLayer")
	if not ore_tilemap or not ground_tilemap:
		printerr("Tilemaps not found.")
		return

	var local_pos = ore_tilemap.to_local(global_position)
	var cell = ore_tilemap.local_to_map(local_pos)

	var material = _get_material_from_tilemap(ore_tilemap, cell)
	if not material:
		material = _get_material_from_tilemap(ground_tilemap, cell)

	if material and material.hardness <= data.maximum_hardness:
		inventory.add_resource(material, 1)
	else:
		print("No valid material found or hardness too high.")

func _get_material_from_tilemap(tilemap: TileMapLayer, cell: Vector2i) -> MaterialData:
	var tile_data = tilemap.get_cell_tile_data(cell)
	if tile_data and tile_data.has_custom_data("Material"):
		return tile_data.get_custom_data("Material") as MaterialData
	return null

func _on_inventory_full_changed(is_full: bool):
	_is_paused = is_full

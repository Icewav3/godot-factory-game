# ExtractionComponent.gd - Handles resource extraction from world

#extraction needs to know abt inventory
extends Node
class_name ExtractionComponent

var extraction_interval: float
var maximum_hardness: int

@onready var parent_buildable: Node = get_parent()

var elapsed_time: float = 0.0
var is_paused: bool = false
var inventory: InventoryComponent

signal resource_extracted(material: MaterialData, amount: int)

func _ready():
	inventory = parent_buildable.inventory
	
	if parent_buildable and parent_buildable.data:
		var data = parent_buildable.data
		if data.extraction_interval <= 0:
			extraction_interval = data.extraction_interval
		if data.maximum_hardness <= 0:
			maximum_hardness = data.maximum_hardness

func start_process(): # to be called by the parent via buildingcomponent
	set_process(true)

func _process(delta: float):
	if is_paused or not inventory:
		return
		
	elapsed_time += delta
	if elapsed_time >= extraction_interval:
		elapsed_time = 0.0
		attempt_extraction()

func attempt_extraction():
	var parent = get_parent().get_parent() #scuffed
	var world = parent.get_parent() #v scuffed
	var ore_tilemap = world.get_node_or_null("OreLayer")
	var ground_tilemap = world.get_node_or_null("GroundLayer")
	
	if not ore_tilemap or not ground_tilemap:
		printerr("Tilemaps not found.")
		return
	
	var local_pos = ore_tilemap.to_local(parent.global_position)
	var cell = ore_tilemap.local_to_map(local_pos)
	var material = get_material_from_tilemap(ore_tilemap, cell)
	
	if not material:
		material = get_material_from_tilemap(ground_tilemap, cell)
	
	if material and material.hardness <= maximum_hardness:
		inventory.add_resource(material, 1)
		emit_signal("resource_extracted", material, 1)
	else:
		print("No valid material found or hardness too high.")

func get_material_from_tilemap(tilemap: TileMapLayer, cell: Vector2i) -> MaterialData:
	var tile_data = tilemap.get_cell_tile_data(cell)
	if tile_data and tile_data.has_custom_data("Material"):
		return tile_data.get_custom_data("Material") as MaterialData
	return null

func pause_extraction():
	is_paused = true

func resume_extraction():
	is_paused = false

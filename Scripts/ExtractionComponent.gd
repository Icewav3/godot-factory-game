# ExtractionComponent.gd - Handles resource extraction from world
extends Node
class_name ExtractionComponent

# Configuration parameters
var extraction_interval: float = 1.0 # default to 1 second
var maximum_hardness: int = 0 # default hardness threshold
var consumed_resources: Dictionary[MaterialData, int] = {}


# References to parent and inventory
var parent_buildable: Node = null
var inventory: InventoryComponent = null

# Internal state
var elapsed_time: float = 0.0
var is_paused: bool = false
var is_active: bool = false

# Signal emitted when resource becomes available
signal resource_available(building, material, amount)
signal resource_needed(building, material, amount)

func setup(buildable: Node, inv: InventoryComponent) -> void:
	"""
	Initializes the component with its parent buildable and inventory.
	Should be called by the parent (Extractor) during ready.
	"""
	parent_buildable = buildable
	inventory = inv

	# Load parameters from buildable data if available
	if parent_buildable.data:
		var data = parent_buildable.data
		if data.extraction_interval > 0:
			extraction_interval = data.extraction_interval
		if data.maximum_hardness > 0:
			maximum_hardness = data.maximum_hardness
		if data.consumed_resources:
			consumed_resources = data.consumed_resources

func _process(delta: float) -> void:
	if not is_active or is_paused or not inventory:
		return

	elapsed_time += delta
	if elapsed_time >= extraction_interval:
		elapsed_time = 0.0
		attempt_extraction()

func attempt_extraction() -> void:
	# Access world tilemaps; keep existing references logic
	var parent_node = parent_buildable
	if not parent_node:
		printerr("Parent buildable not set.")
		return

	# Climb up to world node
	var world = parent_node.get_parent()
	if not world:
		printerr("World node not found.")
		return

	var ore_tilemap = world.get_node_or_null("OreLayer")
	var ground_tilemap = world.get_node_or_null("GroundLayer")
	if not ore_tilemap or not ground_tilemap:
		printerr("Tilemaps not found.")
		return

	var local_pos = ore_tilemap.to_local(parent_node.global_position)
	var cell = ore_tilemap.local_to_map(local_pos)
	var material = get_material_from_tilemap(ore_tilemap, cell)
	if not material:
		material = get_material_from_tilemap(ground_tilemap, cell)

	#REMOVE ITEMS
	for resource in consumed_resources.keys():
		var required_amount = consumed_resources[resource]
		if not inventory.has_enough(resource, required_amount):
			var amount_needed = required_amount - inventory.count(resource)
			if amount_needed <= 0:
				return
			print_rich("[color=orange]%s: Not enough %s to produce.[/color]" % [parent_buildable.name, resource.material_name])
			parent_buildable.emit_signal("resource_needed", parent_buildable, resource, amount_needed)
			return

	# Consume inputs
	for resource in consumed_resources.keys():
		inventory.remove_resource(resource, consumed_resources[resource])
	#ADD ITEMS
	
	if material and material.hardness <= maximum_hardness:
		inventory.add_resource(material, 1)
		emit_signal("resource_available", parent_buildable, material, inventory.count(material))
	else:
		print("No valid material found or hardness too high.")

func get_material_from_tilemap(tilemap: TileMapLayer, cell: Vector2i) -> MaterialData:
	var tile_data = tilemap.get_cell_tile_data(cell)
	if tile_data and tile_data.has_custom_data("Material"):
		return tile_data.get_custom_data("Material") as MaterialData
	return null

func start_process() -> void:
	is_active = true
	set_process(true)

func pause_extraction() -> void:
	is_paused = true

func resume_extraction() -> void:
	is_paused = false

# Drills/WaterDrill.gd
extends BaseDrill

@export var extraction_interval: float = 1.0  # Time in seconds per resource extraction
var timer: float = 0.0

func _ready():
	set_process(true)

func _process(delta: float):
	timer += delta
	if timer >= extraction_interval:
		timer = 0.0
		_extract_resource()

func _extract_resource():
	var world = get_parent()  # Assuming this drill is placed under a "World" node
	var ore_tilemap = world.get_node_or_null("OreLayer")
	var ground_tilemap = world.get_node_or_null("GroundLayer")

	if not ore_tilemap or not ground_tilemap:
		print("Error: One or both tilemap layers are missing!")
		return

	# Convert global position to local position for the tilemaps
	var local_pos = ore_tilemap.to_local(global_position)
	var cell = ore_tilemap.local_to_map(local_pos)

	var material = _get_material_from_tilemap(ore_tilemap, cell)

	if not material:
		material = _get_material_from_tilemap(ground_tilemap, cell)

	if material:
		print("Drill extracting: ", material.material_name)
		# Process material extraction here, e.g., add to inventory
	else:
		print("No extractable material found.")

func _get_material_from_tilemap(tilemap: TileMapLayer, cell: Vector2i) -> MaterialData:
	var tile_data = tilemap.get_cell_tile_data(cell)
	if tile_data:
		return tile_data.get_custom_data("Material") as MaterialData
	return null

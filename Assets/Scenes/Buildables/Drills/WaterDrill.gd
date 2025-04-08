# Drills/WaterDrill.gd
extends BaseDrill

@export var extraction_interval: float = 1.0  # Time in seconds per resource extraction
var timer: float = 0.0 # change to calling parent method?

func _ready():
	set_process(true)

func _process(delta: float):
	timer += delta
	if timer >= extraction_interval:
		timer = 0.0
		_extract_resource()

func _extract_resource():
	var world = get_parent()
	var ore_tilemap = world.get_node_or_null("OreLayer")
	var ground_tilemap = world.get_node_or_null("GroundLayer")

	if not ore_tilemap or not ground_tilemap:
		print("Error: One or both tilemap layers are missing!")
		return

	var local_pos = ore_tilemap.to_local(global_position)
	var cell = ore_tilemap.local_to_map(local_pos)

	var material = _get_material_from_tilemap(ore_tilemap, cell)

	if not material:
		material = _get_material_from_tilemap(ground_tilemap, cell)

	if material:
		InventoryManager.add_resource(material, 1)  # Add extracted material to inventory
	else:
		print("No extractable material found.")

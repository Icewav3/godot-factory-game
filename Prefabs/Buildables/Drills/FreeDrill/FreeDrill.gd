# Drills/FreeDrill/FreeDrill.gd
extends BaseExtractor

@export var extraction_interval: float = 5.0  # Time in seconds per resource extraction (increased for slow extraction)
var timer: float = 0.0

func _ready() -> void:
	super._ready() # Call the parent's _ready() function
	set_process(true) # Ensure _process is running

func _process(delta: float) -> void:
	if _is_paused:
		return  # Don't process if paused

	timer += delta
	if timer >= extraction_interval:
		timer = 0.0
		_extract()

func _extract() -> void:
	var world = get_parent()
	var ore_tilemap = world.get_node_or_null("OreLayer")
	var ground_tilemap = world.get_node_or_null("GroundLayer")

	if not ore_tilemap or not ground_tilemap:
		print("Error: One or both tilemap layers are missing on " + name + "!")
		return

	var local_pos = ore_tilemap.to_local(global_position)
	var cell = ore_tilemap.local_to_map(local_pos)

	var material = _get_material_from_tilemap(ore_tilemap, cell)
	if not material:
		material = _get_material_from_tilemap(ground_tilemap, cell)

	if material:
		inventory.add_resource(material, 1)  # Add extracted material to inventory
	else:
		print(name + ": No extractable material found.")

func consume_fuel(fuel_amount: float) -> bool:
	# This drill doesn't consume fuel, so always return true.
	return true

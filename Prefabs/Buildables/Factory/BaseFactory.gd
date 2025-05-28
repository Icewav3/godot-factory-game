extends Node2D
class_name BaseFactory

@export var data: factory_data
@onready var inventory: InventoryComponent = $InventoryComponent

var _elapsed_time: float = 0.0
var _is_paused: bool = false

func _ready():
	if inventory:
		inventory.full_changed.connect(_on_inventory_full_changed)
		# Pull inventory size from data if not manually set
		if inventory.max_capacity < 0 and data and data.has("max_inventory_capacity"):
			inventory.max_capacity = data.max_inventory_capacity
	else:
		printerr("Error: InventoryComponent not found on " + name + "!")

	if not data:
		printerr("BaseFactory missing factory_data!")
	
	_create_sprite_from_data()
	set_process(true)

func _process(delta: float):
	if _is_paused or not data:
		return

	_elapsed_time += delta
	if _elapsed_time >= data.production_interval:
		_elapsed_time = 0.0
		_produce()

func _create_sprite_from_data():
	if data.sprite:
		var sprite_node = Sprite2D.new()
		sprite_node.texture = data.sprite
		add_child(sprite_node)
		sprite_node.z_index = -1  # Optional: render below other things
	else:
		printerr(name + ": No sprite assigned in data.")

func _produce():
	# Example production logic based on .data
	
	# Check if we have enough input resources
	for resource in data.consumed_resources.keys():
		var required_amount = data.consumed_resources[resource]
		if not inventory.has_enough(resource, required_amount):
			print(name + ": Not enough " + resource.material_name + " to produce.")
			return

	# Remove consumed resources from inventory
	for resource in data.consumed_resources.keys():
		inventory.remove_resource(resource, data.consumed_resources[resource])

	# Add produced resources to inventory
	for resource in data.produced_resource.keys():
		inventory.add_resource(resource, data.produced_resource[resource])

func _on_inventory_full_changed(is_full: bool) -> void:
	_is_paused = is_full
	if _is_paused:
		print(name + ": Production paused - Inventory full.")
	else:
		print(name + ": Production resumed - Inventory not full.")

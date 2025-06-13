extends Node2D
class_name BaseFactory

@export var sprite_node: Node

@export var data: factory_data
@onready var inventory: InventoryComponent = $InventoryComponent

signal resource_available(building, material, amount)
signal resource_needed(building, material, amount)

var _elapsed_time: float = 0.0
var _is_paused: bool = false

func _ready():
	if LogisticsManager.instance:
		LogisticsManager.instance.register_building(self)
	else:
		push_error("LogisticsManager not found!")
		
	if inventory:
		inventory.full_changed.connect(_on_inventory_full_changed)
		# Pull inventory size from data if not manually set
		if inventory.max_capacity <= 0 and data:
			inventory.max_capacity = data.inventory_capacity
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
		sprite_node.texture = data.sprite
		add_child(sprite_node)
		sprite_node.z_index = -1  # Optional: render below other things
	else:
		printerr(name + ": No sprite assigned in data.")

func _produce():
	var missing_resources := false  # Track if any resources are insufficient

	for resource in data.consumed_resources.keys():
		var required_amount := data.consumed_resources[resource]
		if not inventory.has_enough(resource, required_amount):
			missing_resources = true
			var amount_needed := inventory.max_capacity - inventory.count(resource)
			print_rich("[color=orange]%s: Not enough %s to produce.[/color]" % [name, resource.material_name])
			emit_signal("resource_needed", self, resource, amount_needed)

	# Only proceed with production if all required resources are available
	if missing_resources:
		return

	# Remove consumed resources from inventory
	for resource in data.consumed_resources.keys():
		inventory.remove_resource(resource, data.consumed_resources[resource])

	# Add produced resources to inventory
	for resource in data.produced_resource.keys():
		inventory.add_resource(resource, data.produced_resource[resource])
		print_rich("[color=green]%s Produced %s %s[/color]" % [name, str(data.produced_resource[resource]), str(resource.material_name)])
		emit_signal("resource_available", self, resource, inventory.count(resource))
		


func _on_inventory_full_changed(is_full: bool) -> void:
	_is_paused = is_full
	if _is_paused:
		print_rich("[color=yellow]%s Production paused - Inventory full.[/color]" %name)
	else:
		print("[color=green]%s Production resumed - Inventory not full.[/color]" %name)

# ProductionComponent.gd - Handles resource production
extends Node
class_name ProductionComponent

# Configurable via data or export fallback
var production_interval: float = 1.0
var consumed_resources: Dictionary[MaterialData, int] = {}
var produced_resources: Dictionary[MaterialData, int] = {}

# References set via setup()
var parent_buildable: Node = null
var inventory: InventoryComponent = null

# Internal state
var elapsed_time: float = 0.0
var is_paused: bool = false
var is_active: bool = false

signal resource_available(building, material: MaterialData, amount: int)
signal resource_needed(building, material: MaterialData, amount: int)

func setup(buildable: Node, inv: InventoryComponent) -> void:
	"""
	Called by parent (Factory) to initialize data, references, and logic.
	"""
	parent_buildable = buildable
	inventory = inv

	# Pull from building data if not explicitly overridden
	if parent_buildable.data:
		var data = parent_buildable.data
		if production_interval <= 0:
			production_interval = data.production_interval
		if consumed_resources.is_empty():
			consumed_resources = data.consumed_resources
		if produced_resources.is_empty():
			produced_resources = data.produced_resource

func _process(delta: float) -> void:
	if not is_active or is_paused or not inventory:
		return

	elapsed_time += delta
	if elapsed_time >= production_interval:
		elapsed_time = 0.0
		attempt_production()

func attempt_production() -> void:
	var missing = false
	# Verify input availability
	for resource in consumed_resources.keys():
		var required_amount = consumed_resources[resource]
		if not inventory.has_enough(resource, required_amount):
			var amount_needed = required_amount - inventory.count(resource)
			if amount_needed > 0:
				print_rich("[color=orange]%s: Not enough %s to produce.[/color]" % [parent_buildable.name, resource.material_name])
				parent_buildable.emit_signal("resource_needed", parent_buildable, resource, amount_needed)
				missing = true
				
	if missing:
		return
	#check if produced is full before consuming
	for resource in produced_resources.keys():
		if inventory.get_full_status(resource):
			return
	# Consume inputs
	for resource in consumed_resources.keys():
		var success = inventory.remove_resource(resource, consumed_resources[resource])
		if not success:
			return
	# Produce outputs
	for resource in produced_resources.keys():
		var amount = produced_resources[resource]
		var success = inventory.add_resource(resource, amount)
		if not success:
			return
		print_rich("[color=green]%s Produced %s %s[/color]" % [parent_buildable.name, str(amount), str(resource.material_name)])
		parent_buildable.emit_signal("resource_available", parent_buildable, resource, amount)

func start_process() -> void:
	is_active = true
	set_process(true)

func pause_production() -> void:
	is_paused = true
	print_rich("[color=yellow]%s Production paused.[/color]" % parent_buildable.name)

func resume_production() -> void:
	is_paused = false
	print_rich("[color=green]%s Production resumed.[/color]" % parent_buildable.name)

func stop_production() -> void:
	is_active = false
	set_process(false)

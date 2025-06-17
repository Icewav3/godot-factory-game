# ProductionComponent.gd - Handles resource production
extends Node
class_name ProductionComponent

@export var production_interval: float = 1.0
@export var consumed_resources: Dictionary[MaterialData, int] = {}
@export var produced_resources: Dictionary[MaterialData, int] = {}
@export var auto_start: bool = false  # Start immediately or wait for construction

var elapsed_time: float = 0.0
var is_paused: bool = false
var is_active: bool = false
var inventory: InventoryComponent

signal resource_produced(material: MaterialData, amount: int)
signal resource_needed(material: MaterialData, amount: int)

func _ready():
	inventory = get_parent().get_node_or_null("InventoryComponent")
	
	# Get production data from building component if not set
	var building_component = get_parent().get_node_or_null("BuildingComponent")
	if building_component and building_component.building_data:
		var data = building_component.building_data
		if production_interval <= 0:
			production_interval = data.production_interval
		if consumed_resources.is_empty():
			consumed_resources = data.consumed_resources
		if produced_resources.is_empty():
			produced_resources = data.produced_resource
	
	# Connect to construction completion if we have a construction component
	var construction = get_parent().get_node_or_null("ConstructionComponent")
	if construction:
		construction.construction_complete.connect(_on_construction_complete)
	elif auto_start:
		start_production()

func _process(delta: float):
	if not is_active or is_paused or not inventory:
		return
		
	elapsed_time += delta
	if elapsed_time >= production_interval:
		elapsed_time = 0.0
		attempt_production()

func attempt_production():
	# Check if we have enough resources
	for resource in consumed_resources.keys():
		var required_amount = consumed_resources[resource]
		if not inventory.has_enough(resource, required_amount):
			var amount_needed = required_amount - inventory.count(resource)
			print_rich("[color=orange]%s: Not enough %s to produce.[/color]" % [get_parent().name, resource.material_name])
			emit_signal("resource_needed", resource, amount_needed)
			return
	
	# Remove consumed resources
	for resource in consumed_resources.keys():
		inventory.remove_resource(resource, consumed_resources[resource])
	
	# Add produced resources
	for resource in produced_resources.keys():
		var amount = produced_resources[resource]
		inventory.add_resource(resource, amount)
		print_rich("[color=green]%s Produced %s %s[/color]" % [get_parent().name, str(amount), str(resource.material_name)])
		emit_signal("resource_produced", resource, amount)

func start_production():
	is_active = true
	set_process(true)
	print_rich("[color=cyan]%s Production started![/color]" % get_parent().name)

func stop_production():
	is_active = false
	set_process(false)

func pause_production():
	is_paused = true
	print_rich("[color=yellow]%s Production paused.[/color]" % get_parent().name)

func resume_production():
	is_paused = false
	print_rich("[color=green]%s Production resumed.[/color]" % get_parent().name)

func _on_construction_complete():
	start_production()

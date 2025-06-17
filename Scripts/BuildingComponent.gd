# BuildingComponent.gd - Core building functionality as a reusable component
extends Node
class_name BuildingComponent

@export var building_data: Resource  # factory_data or extractor_data
@export var sprite_node_path: NodePath
@export var is_built: bool = false

var sprite_node: Node

signal building_ready
signal resource_available(building, material, amount)
signal resource_needed(building, material, amount)

func _ready():
	sprite_node = get_node_or_null(sprite_node_path)
	
	register_with_logistics()
	setup_sprite()
	setup_inventory()
	
	if is_built:
		emit_signal("building_ready")

func register_with_logistics():
	if LogisticsManager.instance:
		LogisticsManager.instance.register_building(get_parent())
	else:
		push_error("LogisticsManager not found!")

func setup_sprite():
	if building_data and building_data.sprite and sprite_node:
		sprite_node.texture = building_data.sprite
		sprite_node.z_index = -1
	else:
		printerr(get_parent().name + ": No sprite assigned in data or sprite node not found.")

func setup_inventory():
	var inventory = get_parent().get_node_or_null("InventoryComponent")
	if inventory and building_data:
		if inventory.max_capacity <= 0:
			inventory.max_capacity = building_data.inventory_capacity
	else:
		printerr("Error: InventoryComponent not found on " + get_parent().name + "!")

func emit_resource_available(material: MaterialData, amount: int):
	emit_signal("resource_available", get_parent(), material, amount)

func emit_resource_needed(material: MaterialData, amount: int):
	emit_signal("resource_needed", get_parent(), material, amount)

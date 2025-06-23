# BuildingComponent.gd - Core building functionality as a reusable component
extends Node
class_name BuildingComponent

var data: BuildableData
var sprite_node: Node
var progress: float = 0
var construct_time: float
var current_time: float

@onready var parent_buildable: Node = get_parent()

func _ready():
	sprite_node = parent_buildable.sprite
	data = parent_buildable.data

	setup_sprite()

	if data and data.is_constructed:
		progress = 1
		enable_building()
	else:
		printerr("Missing Data connection in BuildingComponent")
	if data and data.construction_time:
		construct_time = data.construction_time
	else:
		printerr("Missing ConstructionTime in Data")

func _process(delta: float):
	if progress >= 1:
		progress = 1
		set_process(false)
	else:
		current_time =+ delta
		progress = current_time / construct_time
		print(progress)
		sprite_node.CanvasItemMaterial.Progress = progress


func enable_building():
	register_with_logistics()
	setup_inventory()
	if parent_buildable.has_method("on_constructed"):
		parent_buildable.on_constructed()
	else:
		push_warning("Parent building has no on_constructed() method")


func register_with_logistics():
	if LogisticsManager.instance:
		LogisticsManager.instance.register_building(get_parent())
	else:
		push_error("LogisticsManager not found!")

func setup_sprite():
	if data and data.sprite and sprite_node:
		sprite_node.texture = data.sprite
		sprite_node.z_index = -1
	else:
		printerr(get_parent().name + ": No sprite assigned in data or sprite node not found.")

func setup_inventory():
	var inventory = get_parent().get_node_or_null("InventoryComponent")
	if inventory and data:
		if inventory.max_capacity <= 0:
			inventory.max_capacity = data.inventory_capacity
	else:
		printerr("Error: InventoryComponent not found on " + get_parent().name + "!")

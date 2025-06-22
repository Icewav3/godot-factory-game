# BuildingComponent.gd - Core building functionality as a reusable component
extends Node
class_name BuildingComponent

var data: BuildableData
var sprite_node: Node
var current_resources: Dictionary[MaterialData, int]
var required_resources: Dictionary[MaterialData, int]

@onready var parent_buildable: Node = get_parent()

func _ready():
	sprite_node = parent_buildable.sprite
	data = parent_buildable.data

	setup_sprite()

	if DictionaryUtils.can_satisfy(data.current_resources, data.required_resources):
		enable_building()
	else:
		#initialize needed materials
		required_resources = data.required_resources


func _process(delta: float):
	var progress: float = get_resource_completion_ratio()
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

func get_resource_completion_ratio() -> float:
	var total_required := 0
	var total_current := 0

	for material : MaterialData in required_resources.keys():
		var required : int = required_resources[material]
		var current : int = current_resources.get(material, 0)  # Default to 0 if not found
		total_required += required
		total_current += min(current, required)  # Cap current to avoid overcounting

	if total_required == 0:
		return 1.0  # If nothing is required, consider it "complete"

	return clamp(float(total_current) / total_required, 0.0, 1.0)


func emit_resource_available(material: MaterialData, amount: int):
	emit_signal("resource_available", get_parent(), material, amount)

func emit_resource_needed(material: MaterialData, amount: int):
	emit_signal("resource_needed", get_parent(), material, amount)

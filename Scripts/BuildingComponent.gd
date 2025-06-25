# BuildingComponent.gd - Core building functionality as a reusable component
extends Node
class_name BuildingComponent

var data: BuildableData
var parent_buildable: Node
var sprite_node: Sprite2D

var progress: float = 0
var construct_time: float = 0.0
var current_time: float = 0.0
var is_constructed: bool = false

func setup(parent: Node) -> void:
	parent_buildable = parent
	data = parent.data if "data" in parent else null
	sprite_node = parent.get_node_or_null("Sprite2D")

	is_constructed = parent_buildable.is_constructed

	if data == null:
		printerr(parent.name + ": Missing BuildableData!")
	else:
		construct_time = data.get_construction_time()
	setup_sprite()
		
	if is_constructed:
		progress = 1
		_set_shader_value(progress)
		enable_building()

func _process(delta: float) -> void:
	if is_constructed:
		return
	if progress >= 1:
		progress = 1
		enable_building()
		return

	current_time += delta
	progress = current_time / construct_time
	_set_shader_value(progress)


func _set_shader_value(value: float) -> void:
	if sprite_node and sprite_node.material:
		var mat := sprite_node.material as ShaderMaterial
		if mat:
			mat.set_shader_parameter("progress", value)
		else:
			printerr("Sprite node's material is not a ShaderMaterial")
	else:
		printerr("Sprite node or its material is missing or invalid.")

func enable_building() -> void:
	is_constructed = true
	print(parent_buildable.name + " is constructed")
	register_with_logistics()
	setup_inventory()
	if parent_buildable.has_method("on_constructed"):
		parent_buildable.on_constructed()
	else:
		push_warning(parent_buildable.name + ": No on_constructed() method.")

func register_with_logistics() -> void:
	if LogisticsManager.instance:
		LogisticsManager.instance.register_building(parent_buildable)
	else:
		push_error("LogisticsManager not found!")

func setup_sprite() -> void:
	if data and data.sprite and sprite_node:
		sprite_node.texture = data.sprite
		sprite_node.z_index = -1
	else:
		printerr(parent_buildable.name + ": Sprite or texture missing in data.")

func setup_inventory() -> void:
	var inventory = parent_buildable.get_node_or_null("InventoryComponent")
	if inventory and data:
		if inventory.max_capacity <= 0:
			inventory.max_capacity = data.inventory_capacity
	else:
		printerr(parent_buildable.name + ": InventoryComponent missing or data invalid.")

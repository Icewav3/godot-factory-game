extends Node2D
class_name Factory

@export var data: BuildableData
@export var is_constructed: bool = false

signal resource_available(building: Node, material: MaterialData, amount: int)
signal resource_needed(building: Node, material: MaterialData, amount: int)

@onready var building: BuildingComponent = $BuildingComponent
@onready var inventory: InventoryComponent = $InventoryComponent
@onready var production: ProductionComponent = $ProductionComponent
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	building.setup(self)
	production.setup(self, inventory)

	
	# Register with global tracker
	if LogisticsManager.instance:
		LogisticsManager.instance.register_building(self)
	else:
		push_error("LogisticsManager not found!")

	# Setup inventory
	if inventory:
		inventory.full_changed.connect(_on_inventory_full_changed)
		if inventory.max_capacity <= 0 and data:
			inventory.max_capacity = data.inventory_capacity
	else:
		printerr("Factory missing InventoryComponent!")

	# Setup production
	if production:
		production.resource_available.connect(_on_resource_produced)
		production.resource_needed.connect(_on_resource_needed)
	else:
		printerr("Factory missing ProductionComponent!")

	# Setup sprite
	_apply_sprite_from_data()

func _apply_sprite_from_data():
	if data and data.sprite:
		sprite.texture = data.sprite
	else:
		printerr("%s: Missing sprite in data." % name)

func _on_inventory_full_changed(is_full: bool):
	if is_full:
		production.pause_production()
	else:
		production.resume_production()

func _on_resource_produced(material: MaterialData, amount: int):
	emit_signal("resource_available", self, material, amount)

func _on_resource_needed(material: MaterialData, amount: int):
	emit_signal("resource_needed", self, material, amount)
	
func on_constructed(): # Called by BuildingComponent when construction is finished
	production.start_process()

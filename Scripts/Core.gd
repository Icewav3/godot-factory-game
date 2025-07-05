# =============================================================================
# Core.gd - Simple coordinator script for starting building
# =============================================================================
extends Node2D
class_name Core

signal resource_needed(building: Node, material: MaterialData, amount: int)

@export var data: BuildableData
@export var is_constructed: bool = true

@onready var building: BuildingComponent = $BuildingComponent
@onready var dock: DroneDockComponent = $DroneDockComponent
@onready var upload: UploadComponent = $UploadComponent
@onready var inventory : InventoryComponent = $InventoryComponent
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	# Connect signals
	building.setup(self)
	dock.setup(self)
	upload.setup(self, inventory)
	apply_sprite_from_data()
	
	if LogisticsManager.instance:
		LogisticsManager.instance.register_building(self)
	else:
		push_error("LogisticsManager not found!")
		
func _on_upload_resource_needed(building: Node, material: MaterialData, amount: int) -> void:
	emit_signal("resource_needed", building, material, amount)
	
func apply_sprite_from_data():
	if data and data.sprite:
		sprite.texture = data.sprite
	else:
		printerr("%s: Missing sprite in data." % name)

func on_constructed(): # Called by BuildingComponent when construction is finished
	dock.activate_dock()
	upload.start_process()

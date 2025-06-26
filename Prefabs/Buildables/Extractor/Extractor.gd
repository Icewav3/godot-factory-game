# Extractor.gd - Simple coordinator script  
extends Node2D
class_name Extractor

signal resource_available(building: Node, material: MaterialData, amount: int)
signal resource_needed(building: Node, material: MaterialData, amount: int)

@export var data: BuildableData
@export var is_constructed: bool = false

@onready var building: BuildingComponent = $BuildingComponent
@onready var inventory: InventoryComponent = $InventoryComponent
@onready var extraction: ExtractionComponent = $ExtractionComponent
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	# Connect signals
	building.setup(self)
	extraction.setup(self, inventory)
	
	if LogisticsManager.instance:
		LogisticsManager.instance.register_building(self)
	else:
		push_error("LogisticsManager not found!")
		
	# Relay extraction signal
	extraction.resource_available.connect(_on_extraction_resource_available)
	extraction.resource_needed.connect(_on_extraction_resource_needed)

	if inventory:
		inventory.full_changed.connect(_on_inventory_full_changed)

func _on_extraction_resource_available(building: Node, material: MaterialData, amount: int) -> void:
	emit_signal("resource_available", building, material, amount)
	
func _on_extraction_resource_needed(building: Node, material: MaterialData, amount: int) -> void:
	emit_signal("resource_needed", building, material, amount)

func _on_inventory_full_changed(is_full: bool):
	if extraction:
		if is_full:
			extraction.pause_extraction()
		else: 
			extraction.resume_extraction()

func on_constructed(): # Called by BuildingComponent when construction is finished
	extraction.start_process()

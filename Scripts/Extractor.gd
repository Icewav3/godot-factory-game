# Extractor.gd - Simple coordinator script  
extends Node2D
class_name Extractor

@export var data: BuildableData

@onready var building: BuildingComponent = $BuildingComponent
@onready var extraction: ExtractionComponent = $ExtractionComponent
@onready var inventory: InventoryComponent = $InventoryComponent
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	# Connect signals
	building.setup(self)
	if inventory:
		inventory.full_changed.connect(_on_inventory_full_changed)

func _on_inventory_full_changed(is_full: bool):
	if extraction:
		if is_full:
			extraction.pause_extraction()
		else: 
			extraction.resume_extraction()

func on_constructed(): #Call when built
	extraction.start_process()

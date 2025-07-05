# =============================================================================
# DroneBay.gd - Simple coordinator script for drone dock building
# =============================================================================
extends Node2D
class_name DroneBay

@export var data: BuildableData
@export var is_constructed: bool = false

@onready var building: BuildingComponent = $BuildingComponent
@onready var dock_component: DroneDockComponent = $DroneDockComponent
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	# Connect signals
	building.setup(self)
	dock_component.setup(self)
	apply_sprite_from_data()
	
	if LogisticsManager.instance:
		LogisticsManager.instance.register_building(self)
	else:
		push_error("LogisticsManager not found!")

func apply_sprite_from_data():
	if data and data.sprite:
		sprite.texture = data.sprite
	else:
		printerr("%s: Missing sprite in data." % name)

func on_constructed(): # Called by BuildingComponent when construction is finished
	dock_component.activate_dock()

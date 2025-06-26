# LaunchPad.gd - Simple coordinator script  
extends Node2D
class_name LaunchPad

signal resource_needed(building: Node, material: MaterialData, amount: int)

@export var data: BuildableData
@export var is_constructed: bool = false

@onready var building: BuildingComponent = $BuildingComponent
@onready var inventory: InventoryComponent = $InventoryComponent
@onready var uploader: UploadComponent = $UploadComponent
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	# Connect signals
	building.setup(self)
	uploader.setup(self, inventory)
	_apply_sprite_from_data()
	# Relay uploader signals
	uploader.resource_needed.connect(_on_upload_resource_needed)
	
func _apply_sprite_from_data():
	if data and data.sprite:
		sprite.texture = data.sprite
	else:
		printerr("%s: Missing sprite in data." % name)

func _on_upload_resource_needed(building: Node, material: MaterialData, amount: int) -> void:
	emit_signal("resource_needed", building, material, amount)

func on_constructed(): # Called by BuildingComponent when construction is finished
	uploader.start_process()

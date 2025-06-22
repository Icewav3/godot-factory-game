extends Resource

class_name BuildableData

@export_category("Buildable Info")
@export var building_name: String = "Placeholder"
@export var health: int = 100
@export var inventory_capacity: int = 10
@export var sprite: Texture2D
@export_category("Construction")
@export var required_resources: Dictionary[MaterialData, int] = {}
@export var current_resources: Dictionary[MaterialData, int] = {}
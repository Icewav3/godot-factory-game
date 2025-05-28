extends Resource

class_name buildable_data

@export var building_name: String = "Placeholder"
@export var health: int = 100
@export var required_resources: Dictionary[MaterialData, int] = {}
@export var inventory_capacity: int = 10
@export var sprite: Texture2D

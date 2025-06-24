extends Resource

class_name BuildableData

@export_category("Buildable Info")
@export var building_name: String = "Placeholder"
@export var health: int = 100
@export var inventory_capacity: int = 10
@export var sprite: Texture2D
@export_category("Construction")
@export var required_resources: Dictionary[MaterialData, int] = {}
@export var construct_time_multiplier: float = 1.0
@export var is_constructed: bool = false

func get_construction_time() -> float:
	return DictionaryUtils.get_total_material_count(required_resources) * construct_time_multiplier

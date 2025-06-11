extends buildable_data

class_name factory_data

@export var production_interval: float = 1
@export var consumed_resources: Dictionary[MaterialData, int] = {}
@export var produced_resource: Dictionary[MaterialData, int] = {}
const SCENE := preload("res://Prefabs/Buildables/Factory/Factory.tscn")

func get_scene() -> PackedScene:
	return SCENE

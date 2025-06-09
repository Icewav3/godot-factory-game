extends buildable_data

class_name extractor_data

@export var extraction_interval: float
@export var maximum_hardness: int = 0
@export var consumed_resources: Dictionary[MaterialData, int] = {}
const SCENE := preload("res://Prefabs/Buildables/Extractor/Extractor.tscn")

func get_scene() -> PackedScene:
	return SCENE

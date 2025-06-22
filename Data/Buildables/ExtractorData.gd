extends BuildableData

class_name ExtractorData

@export var extraction_interval: float = 5
@export var extraction_amount: int = 1
@export var maximum_hardness: int = 0
@export var consumed_resources: Dictionary[MaterialData, int] = {}
const SCENE := preload("res://Prefabs/Buildables/Extractor.tscn")

func get_scene() -> PackedScene:
	return SCENE

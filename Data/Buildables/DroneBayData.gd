extends BuildableData

class_name DroneBayData

@export var drone_capacity: int = 4
@export var dock_radius: float = 50.0 #MAYBE REMOVE
const SCENE := preload("res://Prefabs/Buildables/Logistics/DroneBay.tscn")

func get_scene() -> PackedScene:
	return SCENE

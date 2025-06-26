extends BuildableData

class_name LaunchPadData

@export var upload_interval : float = 5
const SCENE := preload("res://Prefabs/Buildables/LaunchPad/LaunchPad.tscn")

func get_scene() -> PackedScene:
	return SCENE

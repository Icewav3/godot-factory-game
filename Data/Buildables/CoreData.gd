extends BuildableData
class_name CoreData

@export_category("Core - Launch Pad Info")
@export var upload_interval : float = 10

@export_category("Core - Drone Bay Info")
@export var drone_amount: int = 4
@export var drone_speed: int = 200
@export var drone_inventory_capacity: int = 10
@export var dock_radius: float = 150

const SCENE := preload("res://Prefabs/Buildables/NotPlayerPlaced/Core.tscn")
const DRONESCENE := preload("res://Prefabs/Units/TransportDrone/TransportDrone.tscn")

func get_scene() -> PackedScene:
	return SCENE

func get_drone_scene() -> PackedScene:
	return DRONESCENE

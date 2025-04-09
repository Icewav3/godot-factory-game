# Data/DrillData.gd
extends Resource
class_name DrillData
@export var drill_name: String = "Unnamed Drill"
@export var mining_rate: float = 1.0
@export var fuel_types: Dictionary[MaterialData, float] #the material and amount consumed extraction (can be multiple)
@export var extraction_interval: float = 1.0
@export var drill_texture: Texture2D

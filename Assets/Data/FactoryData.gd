# Data/FactoryData.gd
extends Resource
class_name FactoryData
@export var factory_name: String = "Unnamed Factory"
@export var production_interval: float = 3.0  # seconds per production cycle
@export var input_resources: Dictionary[MaterialData, float] = {}  # Recipe: material => required amount
@export var output_resource: MaterialData  # The resource produced by this factory
@export var output_amount: float = 1.0  # Amount produced per cycle
@export var factory_texture: Texture2D  # Texture for UI and in-game representation

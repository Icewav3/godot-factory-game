# Factories/BaseFactory.gd
extends Node2D
class_name BaseFactory

# Each factory instance will have its own configuration file.
@export var factory_data: FactoryData

var timer: float = 0.0

func _ready():
	if not factory_data:
		push_error("FactoryData not set for " + str(self))
		set_process(false)
	else:
		set_process(true)
		# Optionally set the texture
		if factory_data.factory_texture:
			$Sprite2D.texture = factory_data.factory_texture

func _process(delta: float):
	timer += delta
	if timer >= factory_data.production_interval:
		timer = 0.0
		_produce()

func _produce():
	# Check if required resources are available via the InventoryManager singleton.
	for resource in factory_data.input_resources.keys():
		var required = factory_data.input_resources[resource]
		var available = InventoryManager.get_resource_count(resource)
		if available < required:
			print("Not enough ", resource.material_name, " for ", factory_data.factory_name)
			return
	# Consume inputs.
	for resource in factory_data.input_resources.keys():
		InventoryManager.remove_resource(resource, factory_data.input_resources[resource])
	# Produce output.
	InventoryManager.add_resource(factory_data.output_resource, factory_data.output_amount)
	print("Produced ", factory_data.output_amount, " ", factory_data.output_resource.material_name, " at ", factory_data.factory_name)

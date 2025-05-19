# Factories/SiliconFactory.gd
extends BaseFactory

# Define the recipe for silicon production
@export var required_resources: Dictionary[MaterialData, int] = {
}
@export var produced_resource: MaterialData

func _produce():
	# Guard check if required resources are available.
	for resource in required_resources.keys():
		if !inventory.has_enough(resource, required_resources[resource]):
			print("Not enough ", resource.material_name, " to produce ", produced_resource.material_name)
			return
	# Consume resources
	for resource in required_resources.keys():
		inventory.remove_resource(resource, required_resources[resource])
	
	# Add produced resource to singleton
	InventoryManager.add_resource(produced_resource, 1)

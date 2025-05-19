# Factories/SiliconFactory.gd
extends BaseFactory

# Define the recipe for silicon production
@export var required_resources: Dictionary[MaterialData, float] = {
}
@export var produced_resource: MaterialData

func _produce():
	# Check if required resources are available.
	# For this example, we assume a global inventory is available via an autoload "Inventory"
	for resource in required_resources.keys():
		if inventory.has_enough(resource, required_resources[resource]):
			print("Not enough ", resource, " to produce ", produced_resource)
			return
	# Consume resources
	for resource in required_resources.keys():
		inventory.remove_resource(resource, required_resources[resource])
	
	# Add produced resource to singleton
	InventoryManager.add_resource(produced_resource, 1)

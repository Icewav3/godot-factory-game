# Factories/SiliconFactory.gd
extends BaseFactory

# Define the recipe for silicon production
@export var required_resources: Dictionary = {
	"Quartz": 1.0,
	"Sand": 1.0
}
@export var produced_resource: String = "Silicon"

func _produce():
	# Check if required resources are available.
	# For this example, we assume a global inventory is available via an autoload "Inventory"
	for resource in required_resources.keys():
		var available = InventoryManager.items.get(resource, 0)
		if available < required_resources[resource]:
			print("Not enough ", resource, " to produce ", produced_resource)
			return
	
	# Consume resources
	for resource in required_resources.keys():
		InventoryManager.items[resource] -= required_resources[resource]
	
	# Add produced resource
	InventoryManager.add_item(produced_resource, 1)
	print("Produced 1 ", produced_resource, ". Inventory now: ", InventoryManager.items)

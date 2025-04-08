# Scripts/InventoryManager.gd

# THIS IS A SINGLETON AND ACTS AS THE PLAYERS MATERIALS TO SPEND

extends Node

# Dictionary to store resource amounts
var resources: Dictionary = {}

# Add resources to inventory
func add_resource(material: MaterialData, amount: int = 1):
	if not material:
		print("Invalid material")
		return
	
	var name = material.material_name

	if name in resources:
		resources[name] += amount
	else:
		resources[name] = amount

	print("Added ", amount, " of ", name, " to inventory. Total: ", resources[name])

func remove_resource(material: MaterialData, amount: int = 1):
	if not material:
		print("Invalid material")
		return
	
	var name = material.material_name

	if name in resources:
		resources[name] -= amount
	else:
		resources[name] = amount
	print("Removed ", amount, " of ", name, " to inventory. Total: ", resources[name])

# Get current amount of a resource
func get_resource_count(material: MaterialData) -> int:
	return resources.get(material.material_name, 0)

# Debug function to print all inventory contents
func print_inventory():
	print("=== Inventory ===")
	for key in resources.keys():
		print(key, ": ", resources[key])

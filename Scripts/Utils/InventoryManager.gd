extends Node

# Use the MaterialData object as the key
var resources: Dictionary = {}

func add_resource(material: MaterialData, amount: int = 1) -> void:
	if not material:
		print("Invalid material")
		return

	if material in resources:
		resources[material] += amount
	else:
		resources[material] = amount

	print("Added ", amount, " of ", material.material_name, ". Total: ", resources[material])

func remove_resource(material: MaterialData, amount: int = 1) -> void:
	if not material:
		print("Invalid material")
		return

	if material in resources:
		resources[material] -= amount
	else:
		resources[material] = amount

	print("Removed ", amount, " of ", material.material_name, ". Total: ", resources[material])

func get_resource_count(material: MaterialData) -> int:
	return resources.get(material, 0)

func print_inventory() -> void:
	print("=== Inventory ===")
	for mat in resources.keys():
		print(mat.material_name, ": ", resources[mat])

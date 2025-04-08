extends Node
class_name InventoryComponent

# This class is a childcomponent of any buildable

signal inventory_changed(material: MaterialData, new_amount: float)
@export var max_capacity: int = 10  # Optional
var inventory: Dictionary[MaterialData, float] = {}

# Adds a resource, respecting optional capacity limit.
func add_resource(material: MaterialData, amount: float) -> bool:
	if !material:
		return false
	var current = inventory.get(material, 0.0)
	var new_total = current + amount

	# Optional max capacity check (not per resource, just total units)
	if max_capacity > 0 and _get_total_inventory() + amount > max_capacity:
		print("Inventory full.")
		return false

	inventory[material] = new_total
	return true

func remove_resource(material: MaterialData, amount: float) -> bool:
	if !material or material not in inventory:
		return false
	inventory[material] = max(inventory[material] - amount, 0)
	return true

func clear_inventory():
	inventory.clear()

func get_resource_count(material: MaterialData) -> float:
	return inventory.get(material, 0)

func has_enough(material: MaterialData, amount: float) -> bool:
	return get_resource_count(material) >= amount

func _get_total_inventory() -> float:
	var total := 0.0
	for amount in inventory.values():
		total += amount
	return total

func debug_inventory() -> void:
	print("Inventory Contents:")
	for res in inventory.keys():
		print("- ", res.material_name, ": ", inventory[res])

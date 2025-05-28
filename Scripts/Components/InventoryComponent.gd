# Components/InventoryComponent.gd
extends Node
class_name InventoryComponent

signal full_changed(is_full: bool)
signal inventory_changed(material: MaterialData, new_amount: int)

var items: Dictionary = {}
var _is_full: bool = false

var max_capacity: int = -1  # Will be set from parent data

func _ready():
	if max_capacity < 0:
		if get_parent().has_method("get"): # Optional safety check
			var data = get_parent().get("data")
			if data:
				max_capacity = data.inventory_capacity
		else:
			printerr("Parent node does not have 'data' property")


func add_resource(resource: MaterialData, amount: int) -> void:
	var total = get_total_count()
	if total + amount > max_capacity:
		var available_space = max_capacity - total
		if available_space > 0:
			_store(resource, available_space)
			inventory_changed_signal(resource, items[resource])  # Add signal emission here
			_update_full_status()
			return
	_store(resource, amount)
	inventory_changed_signal(resource, items[resource])  # Add signal emission here
	_update_full_status()

func remove_resource(resource: MaterialData, amount: int) -> void:
	if not items.has(resource):
		return
	items[resource] -= amount
	var new_amount = items[resource]
	if new_amount <= 0:
		items.erase(resource)
		new_amount = 0
	inventory_changed_signal(resource, new_amount)  # Add signal emission here
	_update_full_status()



func _store(resource: MaterialData, amount: int) -> void:
	if items.has(resource):
		items[resource] += amount
	else:
		items[resource] = amount
	print(get_parent().name + " has " + str(items[resource]) + " " + str(resource.material_name))


func _update_full_status() -> void:
	var currently_full = get_total_count() >= max_capacity
	if currently_full != _is_full:
		_is_full = currently_full
		print("Inventory full state changed to: ", _is_full)
		emit_signal("full_changed", _is_full)


func has_enough(resource: MaterialData, amount: int) -> bool:
	return items.get(resource, 0) >= amount


func get_total_count() -> int:
	var total := 0
	for count in items.values():
		total += count
	return total



func inventory_changed_signal(resource: MaterialData, amount: int):
	emit_signal("inventory_changed", resource, amount)

# Components/InventoryComponent.gd
extends Node
class_name InventoryComponent

signal full_changed(is_full: bool)
signal inventory_changed(material: MaterialData, new_amount: float)
@export var max_capacity: int = 10

var items: Dictionary = {}
var _is_full: bool    = false


func add_resource(resource: MaterialData, amount: int):
	var total = get_total_count()
	if total + amount > max_capacity:
		var available_space = max_capacity - total
		if available_space > 0:
			_store(resource, available_space)
		_update_full_status()
		return
	_store(resource, amount)
	_update_full_status()


func remove_resource(resource: MaterialData, amount: int):
	if not items.has(resource):
		return
	items[resource] -= amount
	if items[resource] <= 0:
		items.erase(resource)
	_update_full_status()


func _store(resource: MaterialData, amount: int):
	if items.has(resource):
		items[resource] += amount
	else:
		items[resource] = amount


func _update_full_status():
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

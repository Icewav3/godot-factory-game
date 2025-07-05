extends Node
class_name InventoryComponent

signal full_changed(resource: MaterialData, is_full: bool)
signal inventory_changed(material: MaterialData, new_amount: int)

@export var max_capacity: int = -1

var items: Dictionary[MaterialData, int] = {}
var _full_status: Dictionary[MaterialData, bool] = {}

func _ready():
	if max_capacity < 0:
		if get_parent():
			var data = get_parent().get("data")
			if data and data.get("inventory_capacity"):
				max_capacity = data.inventory_capacity
			else:
				print("Parent node does not have 'data' or 'inventory_capacity'")
		else:
			printerr("InventoryComponent fallback to unlimited capacity (max_capacity=-1)")

func add_resource(resource: MaterialData, amount: int) -> bool:
	var current = items.get(resource, 0)
	var limit = max_capacity

	if limit > -1 and current + amount > limit:
		_update_full_status(resource)
		return false

	_store(resource, amount)
	inventory_changed_signal(resource, items[resource])
	_update_full_status(resource)
	return true

func remove_resource(resource: MaterialData, amount: int) -> bool:
	if not items.has(resource):
		return false
	if items[resource] < amount:
		return false

	items[resource] -= amount
	var new_amount = items[resource]
	if new_amount <= 0:
		items.erase(resource)
		new_amount = 0

	inventory_changed_signal(resource, new_amount)
	_update_full_status(resource)
	return true

func get_full_status(resource: MaterialData) -> bool:
	return _full_status.get(resource, false)

func _store(resource: MaterialData, amount: int) -> void:
	if items.has(resource):
		items[resource] += amount
	else:
		items[resource] = amount

	print_rich("[color=lightblue]%s has %s %s[/color]" % [get_parent().name, str(items[resource]), str(resource.material_name)])

func _update_full_status(resource: MaterialData) -> void:
	if max_capacity < 0:
		return  # unlimited

	var count = items.get(resource, 0)
	var is_now_full = count >= max_capacity
	var was_full = _full_status.get(resource, false)

	if is_now_full != was_full:
		_full_status[resource] = is_now_full
		print("Inventory full state for %s: %s" % [resource.material_name, is_now_full])
		emit_signal("full_changed", resource, is_now_full)

func has_enough(resource: MaterialData, amount: int) -> bool:
	return items.get(resource, 0) >= amount

func count(resource: MaterialData) -> int:
	return items.get(resource, 0)

func get_total_count() -> int:
	var total := 0
	for count in items.values():
		total += count
	return total

func inventory_changed_signal(resource: MaterialData, amount: int) -> void:
	emit_signal("inventory_changed", resource, amount)

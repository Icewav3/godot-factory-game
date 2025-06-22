extends Node
class_name InventoryComponent

signal full_changed(is_full: bool)
signal inventory_changed(material: MaterialData, new_amount: int)

var items: Dictionary[MaterialData, int] = {}
var _is_full: bool = false

@export var max_capacity: int = -1  # Can be set manually in editor

func _ready():
	# If not set manually, try to pull from parent node's data
	if max_capacity < 0:
		if get_parent():
			var data = get_parent().get("data")
			if data and data.get("inventory_capacity"):
				max_capacity = data.inventory_capacity
			else:
				print("Parent node does not have 'data' or 'inventory_capacity'")
		else:
			printerr("InventoryComponent fallback to unlimited capacity (max_capacity=-1)")

# Adds up to available space, or fully if enough room
func add_resource(resource: MaterialData, amount: int) -> void:
	var total = get_total_count()
	if max_capacity > -1 and total + amount > max_capacity:
		var available_space = max_capacity - total
		if available_space > 0:
			_store(resource, available_space)
			inventory_changed_signal(resource, items[resource])
			_update_full_status()
			return
		# No space available
		_update_full_status()
		return

	_store(resource, amount)
	inventory_changed_signal(resource, items[resource])
	_update_full_status()

func remove_resource(resource: MaterialData, amount: int) -> void:
	if not items.has(resource):
		return
	items[resource] -= amount
	var new_amount = items[resource]
	if new_amount <= 0:
		items.erase(resource)
		new_amount = 0
	inventory_changed_signal(resource, new_amount)
	_update_full_status()

func _store(resource: MaterialData, amount: int) -> void:
	if items.has(resource):
		items[resource] += amount
	else:
		items[resource] = amount
	print_rich("[color=lightblue]%s has %s %s[/color]" % [get_parent().name, str(items[resource]), str(resource.material_name)])

func _update_full_status() -> void:
	if max_capacity < 0:
		return  # Unlimited inventory
	var currently_full = get_total_count() >= max_capacity
	if currently_full != _is_full:
		_is_full = currently_full
		print("Inventory full state changed to: ", _is_full)
		emit_signal("full_changed", _is_full)

func has_enough(resource: MaterialData, amount: int) -> bool:
	return items.get(resource, 0) >= amount

func count(resource: MaterialData) -> int:
	return items.get(resource, 0)


func get_total_count() -> int:
	var total := 0
	for count in items.values():
		total += count
	return total

func inventory_changed_signal(resource: MaterialData, amount: int):
	emit_signal("inventory_changed", resource, amount)

# Inventory.gd
extends Node
class_name Inventory

var items: Dictionary = {}

func add_item(item_name: String, amount: float):
	items[item_name] = items.get(item_name, 0) + amount

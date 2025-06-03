extends Button

@export var resources: Dictionary[MaterialData, int] = {} # Export the dictionary

func _on_pressed() -> void:
	# Check if InventoryManager exists and has the add_resource method
	if InventoryManager and InventoryManager.has_method("add_resource"):
		for material_data in resources:
			var amount: int = resources[material_data]
			InventoryManager.add_resource(material_data, amount)
	else:
		# Optional: Add a warning if InventoryManager is not found or misconfigured
		push_warning("InventoryManager not found or 'add_resource' method is missing.")

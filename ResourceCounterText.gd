extends Control

@onready var rich_text_label = $HFlowContainer/RichTextLabel

func _process(delta):
	update_inventory_display()

func update_inventory_display():
	rich_text_label.clear()
	rich_text_label.append_text("[b]Inventory:[/b]\n")

	for resource_name in InventoryManager.resources.keys():
		var count = InventoryManager.resources[resource_name]
		rich_text_label.append_text(resource_name + ": [color=yellow]" + str(count) + "[/color]\n")

# Call this function whenever the inventory updates
func _on_inventory_updated():
	update_inventory_display()

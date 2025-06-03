extends Control

@export var inventory_counter: Node
@export var resource_slot_scene: PackedScene

func _process(delta: float) -> void:
	update_inventory_display()

func _ready():
	update_inventory_display()

func update_inventory_display():
	# Clear existing ResourceSlots from the FlowContainer
	for child in inventory_counter.get_children():
		child.queue_free()

	for material_data in InventoryManager.resources.keys():
		var count = InventoryManager.resources[material_data]
		if count <= 0:
			continue

		var slot = resource_slot_scene.instantiate()
		var icon = slot.get_node("Icon")
		var count_label = slot.get_node("Count")

		icon.texture = material_data.sprite
		count_label.text = str(count)

		slot.tooltip_text = material_data.material_name

		inventory_counter.add_child(slot)


func _on_inventory_updated() -> void:
	update_inventory_display()

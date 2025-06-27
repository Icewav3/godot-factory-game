# UploadComponent.gd - Handles resource uploads to orbit  
extends Node
class_name UploadComponent

# Configuration
var upload_interval: float = 1.0

# References
var parent_buildable: Node = null
var inventory: InventoryComponent = null

# Internal state
var elapsed_time: float = 0.0
var is_active: bool = false
var is_paused: bool = false

signal resource_needed(building, material, amount)

func setup(buildable: Node, inv: InventoryComponent) -> void:
	parent_buildable = buildable
	inventory = inv

	if parent_buildable.data:
		var data = parent_buildable.data
		if data.upload_interval and data.upload_interval > 0:
			upload_interval = data.upload_interval

func _process(delta: float) -> void:
	if not is_active or is_paused or not inventory:
		return
	parent_buildable.emit_signal("resource_needed", parent_buildable, null, inventory.max_capacity) #FIXME
	elapsed_time += delta
	if elapsed_time >= upload_interval:
		elapsed_time = 0.0
		upload()

func upload() -> void:
	var uploaded_resources := []

	for resource in inventory.items.keys():
		var amount = inventory.items.get(resource, 0)
		if amount > 0:
			var name = resource.material_name
			InventoryManager.add_resource(resource, amount)
			inventory.remove_resource(resource, amount)
			uploaded_resources.append("%s: %d" % [name, amount])

	if uploaded_resources.size() > 0:
		var summary = String(", ").join(uploaded_resources)
		print_rich("[color=cyan][UPLOAD][/color] Uploaded resources: [b]%s[/b]" % summary)



func start_process() -> void:
	is_active = true
	set_process(true)

func pause_upload() -> void:
	is_paused = true

func resume_upload() -> void:
	is_paused = false

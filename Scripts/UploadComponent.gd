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

# Signals
signal resource_available(building, material, amount)
signal resource_needed(building, material, amount)

func setup(buildable: Node, inv: InventoryComponent) -> void:
	parent_buildable = buildable
	inventory = inv

	if parent_buildable.data:
		var data = parent_buildable.data
		if data.has("upload_interval") and data.upload_interval > 0:
			upload_interval = data.upload_interval

func _process(delta: float) -> void:
	if not is_active or is_paused or not inventory:
		return

	elapsed_time += delta
	if elapsed_time >= upload_interval:
		elapsed_time = 0.0
		upload()

func upload() -> void:
	for resource in inventory.keys():
		var amount = inventory.count(resource)
		InventoryManager.add_resource(resource, amount)
		inventory.remove_resource(resource, amount)

func start_process() -> void:
	is_active = true
	set_process(true)

func pause_upload() -> void:
	is_paused = true

func resume_upload() -> void:
	is_paused = false

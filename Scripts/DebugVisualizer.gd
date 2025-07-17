# DebugVisualizer.gd
extends Node2D
class_name DebugVisualizer

@export var label_scene: PackedScene
@export var line_material: Material

var is_debug_enabled := true
var drone_lines: Dictionary[TransportDrone, Line2D] = {}
var building_labels: Dictionary[Node, FlowContainer] = {}

# Overlay layer for Control-based labels
var label_layer: CanvasLayer

var logisticsManager: LogisticsManager
var droneManager: DroneManager
var buildingTracker: BuildingTracker

func _ready() -> void:
	# Create an overlay layer for labels (Control nodes must be under a CanvasLayer)
	label_layer = CanvasLayer.new()
	label_layer.layer = 1
	add_child(label_layer)
	set_process(true)

func _process(_delta: float) -> void:
	# Toggle debug
	if Input.is_action_just_pressed("toggle_debug"):
		is_debug_enabled = !is_debug_enabled
		_update_visibility()
		return

	if not is_debug_enabled:
		return
	#TEMP
	if is_debug_enabled:
		print("Drone lines count: ", drone_lines.size())
		print("Building labels count: ", building_labels.size())
		for line in drone_lines.values():
			print("Line visible: ", line.visible, " Points: ", line.points)
	#ENDTEMP
	# Initialize managers if not set
	if logisticsManager == null:
		logisticsManager = LogisticsManager.instance
		if logisticsManager == null:
			printerr("[DebugVisualizer] Cannot find LogisticsManager")
			return
		droneManager = logisticsManager.drone_manager
		buildingTracker = logisticsManager.building_tracker

	_update_drone_lines()
	_update_building_labels()

func _update_visibility():
	for line in drone_lines.values():
		line.visible = is_debug_enabled
	for container in building_labels.values():
		container.visible = is_debug_enabled

func _update_drone_lines():
	var drones = droneManager.get_free_drones() + droneManager.busy_drones.keys()
	var i := 0
	for drone in drones:
		var line = drone_lines.get(drone)
		if line == null:
			line = Line2D.new()
			line.width = 2
			line.z_index = 100

			# Generate a visually distinct color using HSV
			var hue = float(i) / max(1, drones.size())
			line.default_color = Color.from_hsv(hue, 0.8, 0.9)

			# Clone and assign material if provided
			if line_material:
				line.material = line_material.duplicate()

			add_child(line)
			drone_lines[drone] = line
			i += 1

		if drone.is_active:
			# Update points in local coords
			var offset = global_position
			var from_point = drone.global_position - offset
			var to_point = drone.target_position - offset
			line.points = [from_point, to_point]
			line.visible = true
		else:
			line.visible = false

func _update_building_labels():
	var buildings = buildingTracker.get_tracked_buildings()
	for building in buildings:
		var container = building_labels.get(building)
		if container == null:
			# Create a FlowContainer for resource slots
			container = FlowContainer.new()
			container.name = "%s_DebugSlots" % building.name
			container.set_h_size_flags(Control.SIZE_SHRINK_CENTER)
			container.set_v_size_flags(Control.SIZE_SHRINK_CENTER)
			label_layer.add_child(container)
			building_labels[building] = container

		# Clear old slots
		for child in container.get_children():
			child.queue_free()

		# Populate offers
		for offer in logisticsManager.offer_map.values():
			if offer.provider == building and offer.material:
				var slot = _create_resource_slot(offer.material, offer.amount, "📦")
				container.add_child(slot)

		# Populate requests
		for req in logisticsManager.request_map.values():
			if req.requester == building and req.material:
				var slot = _create_resource_slot(req.material, req.amount, "🛒")
				container.add_child(slot)

		# Position container above building
		var size_x = container.get_size().x
		container.global_position = building.global_position + Vector2(-size_x / 2, -60)
		container.visible = is_debug_enabled

func _create_resource_slot(material: MaterialData, amount: int, prefix: String) -> Node:
	# Skip wildcard materials
	if material == null:
		return Control.new()

	var slot = label_scene.instantiate()
	var icon = slot.get_node("Icon") as TextureRect
	var count_label = slot.get_node("Count") as Label

	if icon:
		icon.texture = material.sprite
	if count_label:
		count_label.text = "%s %d" % [prefix, amount]

	slot.tooltip_text = material.material_name
	return slot

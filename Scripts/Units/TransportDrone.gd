extends Node2D
class_name TransportDrone

signal transport_finished(drone: TransportDrone)
signal transport_failed(drone: TransportDrone, reason: String)

@onready var inventory: InventoryComponent = $InventoryComponent

@export var speed: float = 200.0  # Pixels per second
var arrival_threshold: float = 4.0  # Distance considered "arrived"

# --- Transport Task Data ---
var source: Node = null
var destination: Node = null
var resource: MaterialData = null
var amount: int = 0

# Drone state
var is_active: bool = false
var moving_to_source: bool = true
var target_position: Vector2

func _ready() -> void:
	inventory.clear()
	is_active = false
	set_process(true)

func _process(delta: float) -> void:
	if not is_active:
		return

	var direction = (target_position - global_position).normalized()
	global_position += direction * speed * delta

	if global_position.distance_to(target_position) < arrival_threshold:
		if moving_to_source:
			_on_arrived_at_source()
		else:
			_on_arrived_at_destination()

func start_transport(from: Node, to: Node, resource_type: MaterialData, quantity: int) -> void:
	if is_active:
		push_error("Drone is already active.")
		emit_signal("transport_failed", self, "Drone busy")
		return

	# Assign task data
	source = from
	destination = to
	resource = resource_type
	amount = quantity
	is_active = true
	moving_to_source = true

	if not _validate_nodes():
		emit_signal("transport_failed", self, "Invalid nodes")
		_reset()
		return

	target_position = source.global_position

func _validate_nodes() -> bool:
	return is_instance_valid(source) and is_instance_valid(destination)

func _on_arrived_at_source() -> void:
	if not _validate_nodes():
		emit_signal("transport_failed", self, "Source lost")
		_reset()
		return

	var source_inventory = source.get_node_or_null("InventoryComponent")
	if source_inventory == null:
		emit_signal("transport_failed", self, "Missing source inventory")
		_reset()
		return

	source_inventory.remove_resource(resource, amount)
	inventory.add_resource(resource, amount)

	# Move to destination
	moving_to_source = false
	target_position = destination.global_position

func _on_arrived_at_destination() -> void:
	if not _validate_nodes():
		emit_signal("transport_failed", self, "Destination lost")
		_reset()
		return

	var dest_inventory = destination.get_node_or_null("InventoryComponent")
	if dest_inventory == null:
		emit_signal("transport_failed", self, "Missing destination inventory")
		_reset()
		return

	inventory.remove_resource(resource, amount)
	dest_inventory.add_resource(resource, amount)

	emit_signal("transport_finished", self)
	_reset()

func _reset() -> void:
	is_active = false
	source = null
	destination = null
	resource = null
	amount = 0
	inventory.clear()

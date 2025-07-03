extends Node2D
class_name TransportDrone

signal transport_finished(drone: TransportDrone)
signal transport_failed(drone: TransportDrone, reason: String)

@onready var inventory: InventoryComponent = $InventoryComponent

@export var speed: float = 200.0
@export var capacity: int = 10
var home_dock: DroneDockComponent = null

var arrival_threshold: float = 4.0

var source: Node = null
var destination: Node = null
var resource: MaterialData = null
var amount: int = 0

var is_active: bool = false
var moving_to_source: bool = true
var target_position: Vector2

func _ready() -> void:
	_reset()
	set_process(true)

func _process(delta: float) -> void:
	if not is_active:
		return
	
	var direction = (target_position - global_position).normalized()
	global_position += direction * speed * delta
	
	if global_position.distance_to(target_position) < arrival_threshold:
		if moving_to_source:
			_pickup_resources()
		else:
			_deliver_resources()

func start_transport(from: Node, to: Node, resource_type: MaterialData, quantity: int) -> bool:
	if is_active:
		return false
	
	source = from
	destination = to
	resource = resource_type
	amount = quantity
	is_active = true
	moving_to_source = true
	target_position = source.global_position
	
	return true

func _pickup_resources() -> void:
	if not is_instance_valid(source):
		_fail("Source destroyed")
		return
	
	var source_inventory = source.get_node_or_null("InventoryComponent")
	if source_inventory == null:
		_fail("No source inventory")
		return
	
	source_inventory.remove_resource(resource, amount)
	inventory.add_resource(resource, amount)

	moving_to_source = false
	target_position = destination.global_position

func _deliver_resources() -> void:
	if not is_instance_valid(destination):
		_fail("Destination destroyed")
		return
	
	var dest_inventory = destination.get_node_or_null("InventoryComponent")
	if dest_inventory == null:
		_fail("No destination inventory")
		return
	
	inventory.remove_resource(resource, amount)
	dest_inventory.add_resource(resource, amount)

	emit_signal("transport_finished", self)
	_reset()

func _fail(reason: String) -> void:
	emit_signal("transport_failed", self, reason)
	_reset()

func _reset() -> void:
	is_active = false
	source = null
	destination = null
	resource = null
	amount = 0
	moving_to_source = true
	inventory.items.clear()

func is_available() -> bool:
	return not is_active

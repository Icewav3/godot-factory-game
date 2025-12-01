extends Node2D
class_name TransportDrone

signal transport_finished(drone: TransportDrone)
signal transport_failed(drone: TransportDrone, reason: String)

@onready var inventory: InventoryComponent = $InventoryComponent

# Movement
@export_group("Movement")
@export var max_speed: float = 800.0
@export var acceleration: float = 400.0
@export var deceleration: float = 600.0
@export_range(0.0, 1000.0) var arrival_slowdown_distance: float = 150

# Hover Bobbing
@export_group("Hover Bobbing")
@export var bobbing_enabled: bool = true
@export var bobbing_amplitude: float = 3.0
@export var bobbing_speed: float = 4.0

@export_group("Capacity")
@export var capacity: int = 10

var home_dock: DroneDockComponent = null
var arrival_threshold: float = 4.0

var source: Node = null
var destination: Node = null
var resource: MaterialData = null
var amount: int = 0

var is_active: bool = false
var moving_to_source: bool = true
var returning_home: bool = false

var target_position: Vector2
var current_speed: float = 0.0
var bobbing_time: float = 0.0
var base_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	_reset()
	base_position = global_position
	set_process(true)

func _process(delta: float) -> void:
	# Always update bobbing, even when idle
	_update_bobbing(delta)

	if not is_active and not returning_home:
		current_speed = move_toward(current_speed, 0.0, deceleration * delta)
		return
	
	var to_target = target_position - base_position
	var distance = to_target.length()

	if distance < arrival_threshold:
		_on_arrival()
		return
	
	var direction = to_target.normalized()

	# Calculate desired speed based on distance (slowdown near target)
	var desired_speed = max_speed
	if distance < arrival_slowdown_distance:
		var slowdown_factor = clamp(distance / arrival_slowdown_distance, 0.1, 1.0)
		desired_speed = max_speed * slowdown_factor
	
	# Accelerate or decelerate toward desired speed
	if current_speed < desired_speed:
		current_speed = move_toward(current_speed, desired_speed, acceleration * delta)
	else:
		current_speed = move_toward(current_speed, desired_speed, deceleration * delta)
	
	# Move base position
	base_position += direction * current_speed * delta

func _update_bobbing(delta: float) -> void:
	bobbing_time += delta * bobbing_speed
	
	if bobbing_enabled:
		var bobbing_offset = sin(bobbing_time) * bobbing_amplitude
		global_position = base_position + Vector2(0, bobbing_offset)
	else:
		global_position = base_position

func _on_arrival() -> void:
	if is_active:
		if moving_to_source:
			_pickup_resources()
		else:
			_deliver_resources()
	elif returning_home:
		_complete_return_home()

func return_to_dock() -> void:
	if not home_dock:
		push_warning("No home dock assigned to drone.")
		return

	target_position = home_dock.parent_buildable.global_position + home_dock._get_dock_position_for(self)
	returning_home = true
	is_active = false
	
func _complete_return_home() -> void:
	returning_home = false
	home_dock.queue_docking(self)

func start_transport(from: Node, to: Node, resource_type: MaterialData, quantity: int) -> bool:
	if is_active:
		return false
	
	if returning_home:
		returning_home = false

	source = from
	destination = to
	resource = resource_type
	amount = quantity
	is_active = true
	moving_to_source = true
	target_position = source.global_position
	base_position = global_position
	
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
	current_speed = 0.0
	inventory.items.clear()
	
func is_available() -> bool:
	return not is_active
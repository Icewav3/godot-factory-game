extends Node
class_name DroneManager

signal all_drones_busy
signal drone_available # ← Restored signal

@export var drone_prefab: PackedScene

var free_drones: Array[TransportDrone] = []
var busy_drones: Dictionary[TransportDrone, DroneDockComponent] = {}
var registered_docks: Array[DroneDockComponent] = []

# -- Register docks and their drones --

func register_dock(dock: DroneDockComponent) -> void:
	if not dock or registered_docks.has(dock):
		return
	registered_docks.append(dock)
	dock.activate_dock()
	dock.connect_to_drone_manager(self)

	var drones = dock.get_owned_drones()
	if drones.size() != dock.drone_amount:
		printerr("[DroneManager] Dock '%s' drone count mismatch: expected %d, got %d" %
			[dock.name, dock.drone_amount, drones.size()])
	for drone in drones:
		_register_drone(drone, dock)

func _register_drone(drone: TransportDrone, dock: DroneDockComponent) -> void:
	free_drones.append(drone)
	add_child(drone)

	drone.transport_finished.connect(_on_drone_finished)
	drone.transport_failed.connect(_on_drone_failed)
	busy_drones[drone] = null
	drone.home_dock = dock

# -- Dispatch --

func dispatch_drone(from: Node, to: Node, resource: MaterialData, amount: int) -> bool:
	if free_drones.is_empty():
		emit_signal("all_drones_busy")
		return false

	var drone = free_drones.pop_back()
	if drone.start_transport(from, to, resource, amount):
		busy_drones[drone] = drone.home_dock
		return true
	else:
		free_drones.append(drone)
		return false

# -- Return handling --

func _on_drone_finished(drone: TransportDrone) -> void:
	_return_drone_to_its_dock(drone)

func _on_drone_failed(drone: TransportDrone, reason: String) -> void:
	print("[DroneManager] Drone failed: ", reason)
	_return_drone_to_its_dock(drone)

func _return_drone_to_its_dock(drone: TransportDrone) -> void:
	var dock = busy_drones.get(drone, null)
	if dock:
		busy_drones[drone] = null
		free_drones.append(drone)
		emit_signal("drone_available")          # ← Re-emit to notify docks
		dock.queue_docking(drone)

# -- Queries --

func get_available_drone_count() -> int:
	return free_drones.size()

func get_busy_drone_count() -> int:
	return busy_drones.size()

func get_free_drones() -> Array[TransportDrone]:
	return free_drones.duplicate()

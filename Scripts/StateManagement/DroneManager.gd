# =============================================================================
# DroneManager.gd - Pure drone fleet management
# =============================================================================
extends Node
class_name DroneManager

signal all_drones_busy
signal drone_available

var free_drones: Array[TransportDrone] = []
var busy_drones: Dictionary[TransportDrone, bool] = {}
var registered_docks: Array[DroneDockComponent] = []

func _ready() -> void:
	pass # No initial spawning — Docks now handle creation

# ----------------------------
# 🔌 Registration
# ----------------------------

func register_dock(dock: DroneDockComponent) -> void:
	if not dock or registered_docks.has(dock):
		return
	registered_docks.append(dock)
	dock.drone_docked.connect(_on_drone_docked)
	dock.drone_undocked.connect(_on_drone_undocked)
	dock.connect_to_drone_manager(self)
	dock.activate_dock()

func deregister_dock(dock: DroneDockComponent) -> void:
	if dock in registered_docks:
		registered_docks.erase(dock)
		dock.drone_docked.disconnect(_on_drone_docked)
		dock.drone_undocked.disconnect(_on_drone_undocked)

func register_drone(drone: TransportDrone) -> void:
	if not drone:
		return
	free_drones.append(drone)
	add_child(drone)

	# Setup drone signals
	drone.transport_finished.connect(_on_drone_finished)
	drone.transport_failed.connect(_on_drone_failed)

func deregister_drone(drone: TransportDrone) -> void:
	if drone in free_drones:
		free_drones.erase(drone)
	if busy_drones.has(drone):
		busy_drones.erase(drone)
	if drone.get_parent() == self:
		drone.queue_free()

# ----------------------------
# 🛰️ Dispatching Logic
# ----------------------------

func dispatch_drone(from: Node, to: Node, resource: MaterialData, amount: int) -> bool:
	if free_drones.is_empty():
		emit_signal("all_drones_busy")
		return false
	
	var drone = free_drones.pop_back()
	if drone.start_transport(from, to, resource, amount):
		busy_drones[drone] = true
		return true
	else:
		free_drones.append(drone)
		return false

# ----------------------------
# 🛬 Drone Return Handling
# ----------------------------

func _on_drone_finished(drone: TransportDrone) -> void:
	_return_drone_to_pool(drone)

func _on_drone_failed(drone: TransportDrone, reason: String) -> void:
	print("Drone failed: ", reason)
	_return_drone_to_pool(drone)

func _return_drone_to_pool(drone: TransportDrone) -> void:
	if busy_drones.has(drone):
		busy_drones.erase(drone)
	if not free_drones.has(drone):
		free_drones.append(drone)
	emit_signal("drone_available") # Notify all docks

# ----------------------------
# 📊 Stats
# ----------------------------

func get_available_drone_count() -> int:
	return free_drones.size()

func get_busy_drone_count() -> int:
	return busy_drones.size()

func get_free_drones() -> Array[TransportDrone]:
	return free_drones.duplicate()

# ----------------------------
# 🧼 Optional Dock Event Hooks
# ----------------------------

func _on_drone_docked(drone: TransportDrone) -> void:
	# Optional: logic if needed
	pass

func _on_drone_undocked(drone: TransportDrone) -> void:
	# Optional: logic if needed
	pass

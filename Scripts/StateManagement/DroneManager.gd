# =============================================================================
# DroneManager.gd - Pure drone fleet management
# =============================================================================
extends Node
class_name DroneManager

signal all_drones_busy
signal drone_available

@export var drone_prefab: PackedScene
var max_drones: int = 4 #TODO Remove the base drones that exist - Create new "Core" buildable, with launchpad and DroneBay but shittier
var free_drones: Array[TransportDrone] = []
var busy_drones: Dictionary[TransportDrone, bool] = {}

func _ready() -> void:
	_spawn_initial_drones()

func _spawn_initial_drones() -> void:
	for i in max_drones:
		_create_drone()

func _create_drone() -> void:
	var drone = drone_prefab.instantiate()
	add_child(drone)
	free_drones.append(drone)
	
	# Connect drone signals
	drone.transport_finished.connect(_on_drone_finished)
	drone.transport_failed.connect(_on_drone_failed)

func dispatch_drone(from: Node, to: Node, resource: MaterialData, amount: int) -> bool:
	if free_drones.is_empty():
		emit_signal("all_drones_busy")
		return false
	
	var drone = free_drones.pop_back()
	if drone.start_transport(from, to, resource, amount):
		busy_drones[drone] = true
		return true
	else:
		# Failed to start transport, return to pool
		free_drones.append(drone)
		return false

func _on_drone_finished(drone: TransportDrone) -> void:
	_return_drone_to_pool(drone)

func _on_drone_failed(drone: TransportDrone, reason: String) -> void:
	print("Drone failed: ", reason)
	_return_drone_to_pool(drone)

func _return_drone_to_pool(drone: TransportDrone) -> void:
	busy_drones.erase(drone)
	free_drones.append(drone)
	emit_signal("drone_available")

func adjust_max_drones(amount: int) -> void:
	max_drones += amount
	if amount > 0:
		for i in amount:
			_create_drone()
	elif amount < 0:
		_destroy_excess_drones(-amount)

func _destroy_excess_drones(amount: int) -> void:
	for i in amount:
		if not free_drones.is_empty():
			var drone = free_drones.pop_back()
			drone.queue_free()
		elif not busy_drones.is_empty():
			var drone = busy_drones.keys()[0]
			busy_drones.erase(drone)
			drone.queue_free()

func get_available_drone_count() -> int:
	return free_drones.size()

func get_busy_drone_count() -> int:
	return busy_drones.size()

## TESTING

#TODO either dronemanager needs to make drones go to their home to idle or they do it themselves
#TODO Potentially add a register/deregister drones method? this way dronebay's can create and register their own drones, and ensure their removal before the buildings destruction?

# =============================================================================
# DroneDockComponent.gd - Handles drone docking and ownership
# =============================================================================
extends Node
class_name DroneDockComponent

var drone_amount: int
var dock_radius: float
var drone_speed: float
var drone_capacity: int
var drone_scene: PackedScene

# Runtime
var parent_buildable: Node = null
var is_active: bool = false
var data: BuildableData

var dock_positions: Array[Vector2] = []
var available_dock_positions: Array[Vector2] = []
var docked_drones: Dictionary[TransportDrone, Vector2] = {}
var owned_drones: Array[TransportDrone] = []

signal drone_docked(drone: TransportDrone)
signal drone_undocked(drone: TransportDrone)

# ------------------------------
# Public API
# ------------------------------

func setup(parent: Node) -> void:
	parent_buildable = parent
	data = null

	if "data" in parent and parent.data:
		data = parent.data
	else:
		printerr(parent.name + ": Missing BuildableData!")

	if data:
		drone_amount = data.drone_amount
		dock_radius = data.dock_radius
		drone_speed = data.drone_speed
		drone_capacity = data.drone_inventory_capacity
		drone_scene = data.get_drone_scene()
	else:
		printerr("[DroneDockComponent] Missing or incomplete buildable data!")




func activate_dock() -> void:
	if is_active:
		return
	_initialize_dock_positions()
	is_active = true
	var drone_manager = LogisticsManager.instance.drone_manager
	_create_and_store_drones(drone_manager)
	print_rich("[color=green][DOCK][/color] Drone dock activated: +%d drone(s)" % drone_amount)
	


func get_owned_drones() -> Array[TransportDrone]:
	return owned_drones.duplicate()

func connect_to_drone_manager(manager: DroneManager) -> void:
	manager.drone_available.connect(_on_drone_available)
	_on_drone_available() # Immediately check

func queue_docking(drone: TransportDrone) -> void:
	if can_dock_drone(drone):
		dock_drone(drone)

# ------------------------------
# Internal Setup
# ------------------------------

func _initialize_dock_positions() -> void:
	dock_positions.clear()
	available_dock_positions.clear()

	var angle_step = TAU / drone_amount
	for i in drone_amount:
		var angle = i * angle_step
		var pos = Vector2(cos(angle), sin(angle)) * dock_radius
		dock_positions.append(pos)
	
	available_dock_positions = dock_positions.duplicate()

#SOMEHOW UN-USED
#func _spawn_owned_drones() -> void:
	#for i in drone_amount:
		#print("is this even running")
		#var drone: TransportDrone = parent_buildable.data.get_scene().instantiate()
		#drone.global_position = parent_buildable.global_position
		#drone.speed = drone_speed
		#drone.capacity = drone_capacity
		#drone.home_dock = self
		#parent_buildable.add_child(drone)
		#owned_drones.append(drone)

# ------------------------------
# Drone Creation
# ------------------------------

func _create_and_store_drones(drone_manager : DroneManager) -> void:
	print("is THIS even running")
	if data:
		var drone_scene = parent_buildable.data.get_drone_scene()
	else:
		printerr("No buildable data for drone instantiation, defualting to exported values")
		
	if not drone_scene:
		printerr("No drone scene found in buildable data")
		return

	for i in drone_amount:
		var drone: TransportDrone = drone_scene.instantiate()
		add_child(drone)
		drone.home_dock = self
		drone.speed = drone_speed
		drone.capacity = drone_capacity #Redundancy
		drone.inventory.max_capacity = drone_capacity
		call_deferred("_queue_initial_return", drone)
		owned_drones.append(drone)
		drone_manager.register_drone(drone, self)

# ------------------------------
# Docking Logic
# ------------------------------
func _queue_initial_return(drone: TransportDrone) -> void:
	if can_dock_drone(drone):
		dock_drone(drone)

func _on_drone_available() -> void:
	if not is_active or available_dock_positions.is_empty():
		return

	for drone in owned_drones:
		if drone.is_available() and not docked_drones.has(drone):
			dock_drone(drone)
			break

func dock_drone(drone: TransportDrone) -> bool:
	if not can_dock_drone(drone):
		return false
	
	var dock_pos = available_dock_positions.pop_back()
	docked_drones[drone] = dock_pos
	
	var world_pos = parent_buildable.global_position + dock_pos
	drone.target_position = world_pos
	drone.return_to_dock()  # Now the drone moves itself

	emit_signal("drone_docked", drone)
	return true


func can_dock_drone(drone: TransportDrone) -> bool:
	return is_active and not available_dock_positions.is_empty() and not docked_drones.has(drone)

func undock_drone(drone: TransportDrone) -> bool:
	if not docked_drones.has(drone):
		return false
	
	var dock_pos = docked_drones[drone]
	docked_drones.erase(drone)
	available_dock_positions.append(dock_pos)
	emit_signal("drone_undocked", drone)
	return true

func _get_dock_position_for(drone: TransportDrone) -> Vector2:
	if docked_drones.has(drone):
		return docked_drones[drone]
	elif not available_dock_positions.is_empty():
		return available_dock_positions.back()
	else:
		return Vector2.ZERO



# ------------------------------
# Cleanup
# ------------------------------

func _exit_tree() -> void:
	_undock_all_drones()

func _undock_all_drones() -> void:
	for drone in docked_drones.keys():
		undock_drone(drone)

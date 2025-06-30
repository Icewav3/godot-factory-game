# =============================================================================
# DroneDockComponent.gd - Handles drone capacity increase and docking
# =============================================================================
extends Node
class_name DroneDockComponent

# Configuration
var drone_capacity_increase: int = 2
var dock_radius: float = 50.0

# References
var parent_buildable: Node = null
var inventory: InventoryComponent = null

# Internal state
var is_active: bool = false
var dock_positions: Array[Vector2] = []
var available_dock_positions: Array[Vector2] = []
var docked_drones: Dictionary[TransportDrone, Vector2] = {}

signal drone_docked(drone: TransportDrone)
signal drone_undocked(drone: TransportDrone)

func setup(buildable: Node) -> void:
	parent_buildable = buildable
	
	if parent_buildable.data:
		var data = parent_buildable.data
		if data.drone_capacity_increase and data.drone_capacity_increase > 0:
			drone_capacity_increase = data.drone_capacity_increase
		if data.dock_radius and data.dock_radius > 0:
			dock_radius = data.dock_radius
	else:
		printerr("DroneDock Cannot Find parent Data")
	_initialize_dock_positions()

func _initialize_dock_positions() -> void:
	# Generate circular dock positions around the building
	var angle_step = 2 * PI / drone_capacity_increase
	for i in drone_capacity_increase:
		var angle = i * angle_step
		var pos = Vector2(cos(angle), sin(angle)) * dock_radius
		dock_positions.append(pos)
	
	available_dock_positions = dock_positions.duplicate()

func activate_dock() -> void:
	if is_active:
		return
	
	is_active = true
	_increase_drone_capacity()
	_connect_to_drone_manager()
	print_rich("[color=green][DOCK][/color] Drone dock activated: +%d drone capacity" % drone_capacity_increase)

func _increase_drone_capacity() -> void:
	if LogisticsManager.instance and LogisticsManager.instance.has_method("get_drone_manager"):
		var drone_manager = LogisticsManager.instance.get_drone_manager()
		if drone_manager:
			drone_manager.adjust_max_drones(drone_capacity_increase)

func _connect_to_drone_manager() -> void:
	if LogisticsManager.instance and LogisticsManager.instance.has_method("get_drone_manager"):
		var drone_manager = LogisticsManager.instance.get_drone_manager()
		if drone_manager:
			drone_manager.drone_available.connect(_on_drone_available)

func _on_drone_available() -> void:
	# When a drone becomes available, try to dock it if there's space
	if not is_active or available_dock_positions.is_empty():
		return
	
	if LogisticsManager.instance and LogisticsManager.instance.has_method("get_drone_manager"):
		var drone_manager = LogisticsManager.instance.get_drone_manager()
		if drone_manager:
			# Find an available drone that's not already docked
			for drone in drone_manager.free_drones:
				if not docked_drones.has(drone) and drone.is_available():
					dock_drone(drone)
					break

func dock_drone(drone: TransportDrone) -> bool:
	if not can_dock_drone(drone):
		return false
	
	var dock_pos = available_dock_positions.pop_back()
	var world_pos = parent_buildable.global_position + dock_pos
	
	docked_drones[drone] = dock_pos
	_move_drone_to_dock(drone, world_pos)
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

func _move_drone_to_dock(drone: TransportDrone, dock_position: Vector2) -> void:
	# Create a simple tween to move drone to dock
	var tween = create_tween()
	tween.tween_property(drone, "global_position", dock_position, 1.0)

func get_dock_position() -> Vector2:
	return parent_buildable.global_position

func get_docked_drone_count() -> int:
	return docked_drones.size()

func get_available_dock_slots() -> int:
	return available_dock_positions.size()

# Cleanup when building is destroyed
func _exit_tree():
	if is_active:
		_decrease_drone_capacity()
		_undock_all_drones()

func _decrease_drone_capacity() -> void:
	if LogisticsManager.instance and LogisticsManager.instance.has_method("get_drone_manager"):
		var drone_manager = LogisticsManager.instance.get_drone_manager()
		if drone_manager:
			drone_manager.adjust_max_drones(-drone_capacity_increase)

func _undock_all_drones() -> void:
	for drone in docked_drones.keys():
		undock_drone(drone)

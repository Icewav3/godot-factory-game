# DebugVisualizer.gd
extends Node2D
class_name DebugVisualizer
## A debug visualization system for displaying drone transport routes and building logistics
## Must be attached as a child of the Camera2D for proper coordinate system alignment

@export_group("Line Properties")
@export var line_width: float = 15
@export var line_z_index: int = 1
@export var color_saturation: float = 0.8
@export var color_brightness: float = 0.9
@export var line_antialiased: bool = true

var is_debug_enabled := true
var drone_lines: Dictionary[TransportDrone, Line2D] = {}
var drone_colors: Dictionary[TransportDrone, Color] = {}
var logisticsManager: LogisticsManager
var droneManager: DroneManager

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	# Toggle debug visualization
	if Input.is_action_just_pressed("toggle_debug"):
		is_debug_enabled = !is_debug_enabled
		update_visibility()
		return
	
	if not is_debug_enabled:
		return
	
	# Initialize manager references on first run
	if logisticsManager == null:
		logisticsManager = LogisticsManager.instance
		if logisticsManager == null:
			printerr("[DebugVisualizer] Cannot find LogisticsManager")
			return
		droneManager = logisticsManager.drone_manager
	
	update_drone_lines()

## Updates visibility of all debug elements based on debug state
func update_visibility() -> void:
	for line in drone_lines.values():
		line.visible = is_debug_enabled
		line.points = []

## Creates and updates Line2D elements showing drone transport routes
func update_drone_lines() -> void:
	var drones = droneManager.get_free_drones() + droneManager.busy_drones.keys()
	
	# Assign colors to new drones first
	for i in range(drones.size()):
		var drone = drones[i]
		if not drone_colors.has(drone):
			drone_colors[drone] = generate_distinct_color(i)
	
	# Create/update lines for each drone
	for drone in drones:
		var line = drone_lines.get(drone)
		
		# Create new line if needed
		if line == null:
			line = Line2D.new()
			line.width = line_width
			line.z_index = line_z_index
			line.antialiased = line_antialiased
			line.default_color = drone_colors[drone]
			
			add_child(line)
			drone_lines[drone] = line
		
		# Update line visibility and route
		if drone.is_active and drone.target_position != Vector2.ZERO:
			# Convert global positions to camera-relative coordinates
			var from_point = to_local(drone.global_position)
			var to_point = to_local(drone.target_position)
			line.points = [from_point, to_point]
			line.visible = true
		else:
			line.visible = false
	
	# Clean up lines for drones that no longer exist
	cleanup_unused_lines(drones)

## Generates visually distinct colors using multiple strategies
func generate_distinct_color(index: int) -> Color:
	# Use golden ratio for better distribution of hues
	var golden_ratio = 0.618033988749895
	var hue = fmod(index * golden_ratio, 1.0)
	
	# Vary saturation and brightness in patterns to increase distinctness
	var sat_pattern = [0.9, 0.7, 1.0, 0.8, 0.6]
	var bright_pattern = [0.9, 1.0, 0.7, 0.8, 0.6]
	
	var saturation = sat_pattern[index % sat_pattern.size()] * color_saturation
	var brightness = bright_pattern[index % bright_pattern.size()] * color_brightness
	
	# Ensure minimum visibility
	saturation = max(saturation, 0.4)
	brightness = max(brightness, 0.5)
	
	return Color.from_hsv(hue, saturation, brightness)

## Removes lines for drones that are no longer active
func cleanup_unused_lines(current_drones: Array) -> void:
	var drones_to_remove: Array[TransportDrone] = []
	
	for drone in drone_lines.keys():
		if drone not in current_drones:
			drones_to_remove.append(drone)
	
	for drone in drones_to_remove:
		if drone_lines.has(drone):
			drone_lines[drone].queue_free()
			drone_lines.erase(drone)
		if drone_colors.has(drone):
			drone_colors.erase(drone)

# =============================================================================
# BuildingTracker.gd - Building lifecycle management
# =============================================================================
extends Node
class_name BuildingTracker

signal building_added(building: Node)
signal building_removed(building: Node)

var tracked_buildings: Dictionary[Node, bool] = {}

func _ready() -> void:
	# Connect to existing buildings in scene
	_scan_existing_buildings()

func _scan_existing_buildings() -> void:
	var _existing_buildables = get_tree().get_nodes_in_group("Buildable")
	print_rich("[color=yellow]Found "+str(_existing_buildables.size())+" existing buildables.[/color]") #TODO Can remove this?
	for node in _existing_buildables:
		_track_building(node)

func _track_building(building: Node) -> void:
	if building in tracked_buildings:
		return
	
	tracked_buildings[building] = true
	
	var dock_component: DroneDockComponent = null
	for child in building.get_children():
		if child is DroneDockComponent:
			dock_component = child
			break
	
	if dock_component:
		get_parent().drone_manager.register_dock(dock_component)
	
	# Connect to building's resource signals if they exist
	if building.has_signal("resource_available"):
		building.resource_available.connect(_on_resource_available)
	if building.has_signal("resource_needed"):
		building.resource_needed.connect(_on_resource_needed)
	
	# Connect to destruction signal
	building.tree_exiting.connect(_on_building_destroyed.bind(building))
	
	emit_signal("building_added", building)

func _on_building_destroyed(building: Node) -> void:
	tracked_buildings.erase(building)
	emit_signal("building_removed", building)

func _on_resource_available(building: Node, material: MaterialData, amount: int) -> void:
	if LogisticsManager.instance:
		LogisticsManager.instance._on_resource_available(building, material, amount)

func _on_resource_needed(building: Node, material: MaterialData, amount: int) -> void:
	if LogisticsManager.instance:
		LogisticsManager.instance._on_resource_needed(building, material, amount)

# Public method for manual building registration (when buildings are placed)
func register_building(building: Node) -> void:
	_track_building(building)

func get_tracked_buildings() -> Array[Node]:
	return tracked_buildings.keys()

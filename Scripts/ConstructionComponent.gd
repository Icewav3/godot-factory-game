# ConstructionComponent.gd - Handles building construction
extends Node
class_name ConstructionComponent

@export var required_resources: Dictionary[MaterialData, int] = {}
@export var shader_sprite_path: NodePath  # Path to sprite with construction shader

var current_resources: Dictionary[MaterialData, int] = {}
var build_progress: float = 0.0
var shader_sprite: Node

signal construction_complete
signal construction_progress_changed(progress: float)

func _ready():
	shader_sprite = get_node_or_null(shader_sprite_path)
	
	# Get required resources from building data if not set
	var building_component = get_parent().get_node_or_null("BuildingComponent")
	if building_component and building_component.building_data and required_resources.is_empty():
		required_resources = building_component.building_data.required_resources
	
	# Initialize current resources to zero
	for material in required_resources.keys():
		current_resources[material] = 0
	
	update_build_progress()

func add_construction_material(material: MaterialData, amount: int) -> bool:
	if not required_resources.has(material):
		return false
		
	var needed = required_resources[material]
	var current = current_resources.get(material, 0)
	var can_add = min(amount, needed - current)
	
	if can_add > 0:
		current_resources[material] = current + can_add
		update_build_progress()
		return true
	return false

func update_build_progress():
	var total_required = 0
	var total_gathered = 0
	
	for material in required_resources.keys():
		total_required += required_resources[material]
		total_gathered += current_resources.get(material, 0)
	
	if total_required > 0:
		build_progress = float(total_gathered) / float(total_required)
	else:
		build_progress = 1.0
	
	emit_signal("construction_progress_changed", build_progress)
	
	# Update shader if we have one
	if shader_sprite and shader_sprite.material:
		shader_sprite.material.set_shader_parameter("progress", build_progress)
	
	if build_progress >= 1.0:
		emit_signal("construction_complete")

func get_needed_materials() -> Dictionary[MaterialData, int]:
	var needed = {}
	for material in required_resources.keys():
		var required = required_resources[material]
		var current = current_resources.get(material, 0)
		if current < required:
			needed[material] = required - current
	return needed

func is_construction_complete() -> bool:
	return build_progress >= 1.0

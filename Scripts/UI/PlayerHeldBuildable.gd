extends Node

const snap := preload("res://Scripts/Utils/snap.gd")
@export var BuildGhostScene : PackedScene

const scale = Vector2(1, 1)
@onready var tilemap: TileMapLayer = get_tree().get_root().get_node("Main/World/GroundLayer")

var current_buildable: BuildableData
var ghost_instance: Node2D
var ui_is_active: bool = false  # Track UI state

func _ready():
	set_process(true)
	set_process_input(true)

func _process(_delta: float) -> void:
	if ghost_instance and current_buildable:
		var mouse_global := _get_world_mouse_position()
		ghost_instance.global_position = snap.snap_to_grid(mouse_global, tilemap)
		ghost_instance.set_valid(_is_valid_placement(ghost_instance.global_position))

func _get_world_mouse_position() -> Vector2:
	var cam := get_viewport().get_camera_2d()
	return cam.get_global_mouse_position() if cam else get_viewport().get_mouse_position()

func _input(event: InputEvent) -> void:
	# Cancel always works, regardless of UI state
	if event.is_action_pressed("ui_cancel"):
		_clear_buildable()
		return
	
	# Only handle building placement if UI is not active
	if event.is_action_pressed("interact") and not ui_is_active:
		if current_buildable and ghost_instance:
			_try_place_buildable()

# Connect these to your build menu signals
func _on_build_menu_panel_build_button_pressed(data: BuildableData) -> void:
	current_buildable = data
	print("Selected via signal: ", data.building_name)
	_spawn_ghost(data)

func _on_build_menu_panel_menu_interaction_started():
	ui_is_active = true

func _on_build_menu_panel_menu_interaction_ended():
	ui_is_active = false

func _on_toggle_button_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		_clear_buildable()
	ui_is_active = toggled_on

func _clear_buildable():
	if current_buildable:
		print("Canceled placement of:", current_buildable.building_name)
	current_buildable = null
	if ghost_instance:
		ghost_instance.queue_free()
		ghost_instance = null

func _try_place_buildable() -> void:
	print("TEST")
	if not (current_buildable and ghost_instance):
		push_warning("Missing buildable or ghost")
		return

	var place_pos := snap.snap_to_grid(_get_world_mouse_position(), tilemap)

	if not _is_valid_placement(place_pos):
		print("❌ Invalid placement")
		return

	var building : Node2D = current_buildable.get_scene().instantiate()
	building.global_position = place_pos

	# Pass data to new instance
	if building.has_method("set_buildable_data"):
		building.set_buildable_data(current_buildable)
	elif "data" in building:
		building.data = current_buildable
	else:
		push_warning("Could not set buildable data on new building")

	$"/root/Main/World".add_child(building)
	print("✅ Placed:", current_buildable.building_name, " at ", place_pos)
	_clear_buildable()

func _spawn_ghost(data: BuildableData) -> void:
	if ghost_instance:
		ghost_instance.queue_free()

	ghost_instance = BuildGhostScene.instantiate()
	add_child(ghost_instance)
	ghost_instance.scale = scale
	ghost_instance.call("set_texture", data.sprite)


func _is_valid_placement(pos: Vector2) -> bool:
	if not ghost_instance:
		return false
	
	# Get the ghost's Area2D
	var ghost_area = ghost_instance.get_node("Area2D")
	if not ghost_area:
		push_warning("Ghost instance missing Area2D")
		return false
	
	# Temporarily move ghost to test position
	var original_pos = ghost_instance.global_position
	ghost_instance.global_position = pos
	
	# Force physics update
	get_tree().physics_frame
	
	# Check for overlapping areas (existing buildings)
	var overlapping_areas = ghost_area.get_overlapping_areas()
	var is_valid = overlapping_areas.size() == 0
	
	# Restore original position
	ghost_instance.global_position = original_pos
	
	# Update ghost color based on validity
	if is_valid:
		ghost_instance.modulate = Color.GREEN
	else:
		ghost_instance.modulate = Color.RED
	
	return is_valid

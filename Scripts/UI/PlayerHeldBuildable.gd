extends Node

const Snap := preload("res://Scripts/Utils/snap.gd")
const BuildGhostScene := preload("res://Prefabs/GUI/BuildPreview.tscn")  # Your preview scene

# TEMP
const scale = Vector2(0.5, 0.5)

@onready var tilemap: TileMapLayer = get_tree().get_root().get_node("Main/World/GroundLayer")  # Update path

var current_buildable: buildable_data
var ghost_instance: Node2D

func _ready():
	set_process(true)
	set_process_input(true)

func _process(_delta: float) -> void:
	if ghost_instance and current_buildable:
		var mouse_pos = get_viewport().get_mouse_position()
		var snapped_pos = Snap.snap_to_grid(mouse_pos, tilemap)
		ghost_instance.global_position = snapped_pos

		var valid = _is_valid_placement(snapped_pos)
		ghost_instance.call("set_valid", valid)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_clear_buildable()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_try_place_buildable()

func _on_build_menu_panel_build_button_pressed(data: buildable_data) -> void:
	current_buildable = data
	print("Selected via signal: ", data.building_name)
	_spawn_ghost(data)

func _on_toggle_button_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		_clear_buildable()

func _clear_buildable():
	if current_buildable:
		print("Canceled placement of:", current_buildable.building_name)
	current_buildable = null
	if ghost_instance:
		ghost_instance.queue_free()
		ghost_instance = null

func _try_place_buildable():
	if not current_buildable or not ghost_instance:
		return

	var snapped_pos = Snap.snap_to_grid(get_viewport().get_mouse_position(), tilemap)
	if not _is_valid_placement(snapped_pos):
		print("❌ Invalid placement")
		return

	# Emit a signal or perform real placement here
	print("✅ Placed:", current_buildable.building_name, " at ", snapped_pos)
	
	
	

	_clear_buildable()

func _spawn_ghost(data: buildable_data) -> void:
	if ghost_instance:
		ghost_instance.queue_free()

	ghost_instance = BuildGhostScene.instantiate()
	add_child(ghost_instance)
	ghost_instance.scale = scale
	ghost_instance.call("set_texture", data.sprite)
	add_child(ghost_instance)

func _is_valid_placement(pos: Vector2) -> bool:
	# Stub for now. Add collision, tile or area checks here
	return true

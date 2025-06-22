@tool
extends EditorPlugin

const REGISTRY_PATH := "res://Data/Buildables/buildable_registry.tres"
const EXTRACTOR_DIR := "res://Data/Buildables/Extractor/"
const FACTORY_DIR := "res://Data/Buildables/Factory/"
const REGISTRY_SCRIPT := preload("res://Data/Buildables/BuildableRegistry.gd")

var panel : HBoxContainer
var button : Button

func _enter_tree() -> void:
	panel = HBoxContainer.new()
	button = Button.new()
	button.text = "Update Buildable Registry"
	button.pressed.connect(_on_button_pressed)
	panel.add_child(button)
	add_control_to_bottom_panel(panel, "Buildable Registry")

func _exit_tree() -> void:
	remove_control_from_bottom_panel(panel)
	panel = null
	button = null

func _on_button_pressed() -> void:
	var registry : BuildableRegistry = REGISTRY_SCRIPT.new()
	registry.extractors = _load_buildables_from(EXTRACTOR_DIR)
	registry.factories = _load_buildables_from(FACTORY_DIR)

	var err = ResourceSaver.save(registry, REGISTRY_PATH)
	if err != OK:
		push_error("Failed to save buildable registry: " + str(err))
	else:
		print("Buildable registry updated and saved to ", REGISTRY_PATH)

func _load_buildables_from(path: String) -> Array[BuildableData]:
	var result : Array[BuildableData] = []

	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var res_path = path + file_name
				var res = load(res_path)
				if res is BuildableData:
					result.append(res)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		push_error("Could not open directory: " + path)

	return result

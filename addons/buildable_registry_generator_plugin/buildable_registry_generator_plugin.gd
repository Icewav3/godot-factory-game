@tool
extends EditorPlugin

const REGISTRY_PATH := "res://Data/Buildables/buildable_registry.tres"
const EXTRACTOR_DIR := "res://Data/Buildables/Extractor/"
const FACTORY_DIR := "res://Data/Buildables/Factory/"
const LOGISTICS_DIR := "res://Data/Buildables/Logistics/"
const REGISTRY_SCRIPT := preload("res://Data/Buildables/BuildableRegistry.gd")

var dock_panel : Control
var main_container : VBoxContainer
var button_container : HBoxContainer
var update_button : Button
var overwrite_checkbox : CheckBox
var preview_container : VBoxContainer
var preview_scroll : ScrollContainer
var preview_content : VBoxContainer

func _enter_tree() -> void:
	_create_dock_ui()
	add_control_to_dock(DOCK_SLOT_LEFT_UR, dock_panel)
	_load_and_display_registry()

func _exit_tree() -> void:
	remove_control_from_docks(dock_panel)
	dock_panel = null

func _create_dock_ui() -> void:
	# Main dock panel
	dock_panel = Control.new()
	dock_panel.name = "Buildable Registry"
	dock_panel.set_custom_minimum_size(Vector2(250, 400))
	
	# Main container
	main_container = VBoxContainer.new()
	dock_panel.add_child(main_container)
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Title label
	var title_label = Label.new()
	title_label.text = "Buildable Registry Manager"
	title_label.add_theme_font_override("font", EditorInterface.get_editor_theme().get_font("bold", "EditorFonts"))
	main_container.add_child(title_label)
	
	# Separator
	var separator1 = HSeparator.new()
	main_container.add_child(separator1)
	
	# Button container
	button_container = HBoxContainer.new()
	main_container.add_child(button_container)
	
	# Update button
	update_button = Button.new()
	update_button.text = "Update Registry"
	update_button.pressed.connect(_on_update_button_pressed)
	button_container.add_child(update_button)
	
	# Overwrite checkbox
	overwrite_checkbox = CheckBox.new()
	overwrite_checkbox.text = "Overwrite"
	overwrite_checkbox.button_pressed = true
	overwrite_checkbox.tooltip_text = "Allow overwriting existing registry file"
	main_container.add_child(overwrite_checkbox)
	
	# Another separator
	var separator2 = HSeparator.new()
	main_container.add_child(separator2)
	
	# Preview section label
	var preview_label = Label.new()
	preview_label.text = "Registry Preview:"
	main_container.add_child(preview_label)
	
	# Preview scroll container
	preview_scroll = ScrollContainer.new()
	preview_scroll.set_custom_minimum_size(Vector2(0, 300))
	preview_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.add_child(preview_scroll)
	
	# Preview content container
	preview_content = VBoxContainer.new()
	preview_scroll.add_child(preview_content)

func _on_update_button_pressed() -> void:
	# Check if file exists and overwrite is disabled
	if FileAccess.file_exists(REGISTRY_PATH) and not overwrite_checkbox.button_pressed:
		_log_warning("Registry file already exists. Enable 'Overwrite' to replace it.")
		return
	
	_log_info("Starting buildable registry update...")
	
	var registry : BuildableRegistry = REGISTRY_SCRIPT.new()
	
	# Load buildables from each directory
	registry.extractors = _load_buildables_from(EXTRACTOR_DIR)
	registry.factories = _load_buildables_from(FACTORY_DIR)
	registry.logistics = _load_buildables_from(LOGISTICS_DIR)
	
	# Save the registry
	var err = ResourceSaver.save(registry, REGISTRY_PATH)
	if err != OK:
		_log_error("Failed to save buildable registry: " + str(err))
	else:
		_log_success("Buildable registry updated and saved to " + REGISTRY_PATH)
		_update_preview_display(registry)

func _load_buildables_from(path: String) -> Array[BuildableData]:
	var result : Array[BuildableData] = []
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var loaded_count = 0
		
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var res_path = path + file_name
				var res = load(res_path)
				if res is BuildableData:
					result.append(res)
					loaded_count += 1
				else:
					_log_warning("File " + file_name + " is not a valid BuildableData resource")
			file_name = dir.get_next()
		dir.list_dir_end()
		
		_log_info("Loaded " + str(loaded_count) + " buildables from " + path)
	else:
		_log_error("Could not open directory: " + path)
	
	return result

func _load_and_display_registry() -> void:
	if FileAccess.file_exists(REGISTRY_PATH):
		var registry = load(REGISTRY_PATH) as BuildableRegistry
		if registry:
			_update_preview_display(registry)
		else:
			_log_warning("Could not load existing registry file")
	else:
		_log_info("No existing registry file found")

func _update_preview_display(registry: BuildableRegistry) -> void:
	# Clear existing preview content
	for child in preview_content.get_children():
		child.queue_free()
	
	# Create sections for each category
	_create_preview_section("Extractors", registry.extractors)
	_create_preview_section("Factories", registry.factories)
	_create_preview_section("Logistics", registry.logistics)
	
	# Summary
	var total_count = registry.extractors.size() + registry.factories.size() + registry.logistics.size()
	var summary_label = Label.new()
	summary_label.text = "Total Items: " + str(total_count)
	summary_label.add_theme_color_override("font_color", Color.CYAN)
	preview_content.add_child(summary_label)

func _create_preview_section(section_name: String, items: Array[BuildableData]) -> void:
	# Section header
	var section_label = Label.new()
	section_label.text = section_name + " (" + str(items.size()) + "):"
	section_label.add_theme_color_override("font_color", Color.YELLOW)
	preview_content.add_child(section_label)
	
	# Items list
	if items.size() > 0:
		for item in items:
			var item_label = Label.new()
			# Try to get a meaningful name from the buildable data
			var item_name = "Unknown"
			if item.has_method("get_display_name"):
				item_name = item.get_display_name()
			elif "name" in item:
				item_name = str(item.name)
			elif "id" in item:
				item_name = str(item.id)
			else:
				item_name = item.resource_path.get_file().get_basename()
			
			item_label.text = "  • " + item_name
			item_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
			preview_content.add_child(item_label)
	else:
		var empty_label = Label.new()
		empty_label.text = "  (No items)"
		empty_label.add_theme_color_override("font_color", Color.GRAY)
		preview_content.add_child(empty_label)
	
	# Add some spacing
	var spacer = Control.new()
	spacer.set_custom_minimum_size(Vector2(0, 5))
	preview_content.add_child(spacer)

# Colored logging functions
func _log_success(message: String) -> void:
	print_rich("[color=green][SUCCESS][/color] " + message)

func _log_error(message: String) -> void:
	print_rich("[color=red][ERROR][/color] " + message)
	push_error(message)

func _log_warning(message: String) -> void:
	print_rich("[color=yellow][WARNING][/color] " + message)
	push_warning(message)

func _log_info(message: String) -> void:
	print_rich("[color=cyan][INFO][/color] " + message)

extends Control

const REGISTRY_PATH := "res://Data/Buildables/buildable_registry.tres"
const buildable_data = preload("res://Data/BuildableData.gd")
signal build_button_pressed(data: buildable_data)
@export var icon_size = 256
@onready var tab_container: TabContainer = $BuildTabContainer
@onready var extractor_list: VBoxContainer = tab_container.get_node("Extractors/ExtractorsList")
@onready var factory_list: VBoxContainer = tab_container.get_node("Factories/FactoriesList")
@onready var logistics_list: VBoxContainer = tab_container.get_node("Logistics/LogisticsList")

func _ready():
	var registry = load(REGISTRY_PATH)
	if registry:
		_populate_buttons(registry)
	else:
		push_error("Could not load buildable registry at: " + REGISTRY_PATH)

func _populate_buttons(registry):
	_clear_children(extractor_list)
	_clear_children(factory_list)
	_clear_children(logistics_list)

	for data in registry.extractors:
		extractor_list.add_child(_create_build_button(data))

	for data in registry.factories:
		factory_list.add_child(_create_build_button(data))
		
	for data in registry.logistics:
		logistics_list.add_child(_create_build_button(data))

func _create_build_button(data: buildable_data) -> Button:
	var button := Button.new()
	button.icon = data.sprite
	button.tooltip_text = data.building_name
	button.expand_icon = true
	button.flat = true
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(icon_size, icon_size) # optional

	button.pressed.connect(_on_build_button_pressed.bind(data))
	return button

func _on_build_button_pressed(data: buildable_data):
	emit_signal("build_button_pressed", data)

func _clear_children(container: Node):
	for child in container.get_children():
		child.queue_free()

func _on_toggle_button_toggled(toggled_on: bool) -> void:
	visible = toggled_on
	

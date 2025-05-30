extends PanelContainer

const REGISTRY_PATH := "res://Data/Buildables/buildable_registry.tres"

@onready var tab_container: TabContainer = $BuildTabContainer
@onready var extractor_list: VBoxContainer = tab_container.get_node("ExtractorsTab/Scroll/DrillsList")
@onready var factory_list: VBoxContainer = tab_container.get_node("FactoriesTab/Scroll/FactoryList")

func _ready():
	var registry = load(REGISTRY_PATH)
	if registry:
		_populate_buttons(registry)
	else:
		push_error("❌ Could not load buildable registry at: " + REGISTRY_PATH)

func _populate_buttons(registry):
	# Clear old buttons first (optional)
	_clear_children(extractor_list)
	_clear_children(factory_list)

	for data in registry.extractors:
		var button = _create_build_button(data)
		extractor_list.add_child(button)

	for data in registry.factories:
		var button = _create_build_button(data)
		factory_list.add_child(button)

func _create_build_button(data: buildable_data) -> Button:
	var button := Button.new()
	button.icon = data.sprite
	button.tooltip_text = data.building_name
	button.expand_icon = true  # Optional: Scales icon better
	button.flat = true         # Optional: More visual space

	# Properly close the lambda and connection
	button.pressed.connect(func():
		print("Selected buildable:", data.building_name)
		# TODO: Hook up building placement
	)

	return button

func _on_toggle_button_toggled(toggled_on: bool) -> void:
	visible = toggled_on

func _clear_children(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()
